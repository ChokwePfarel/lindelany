const { onSchedule } = require("firebase-functions/v2/scheduler");
const { logger } = require("firebase-functions");

/**
 * Scheduled function to clean up inactive documents older than 24 hours
 * Runs twice a month (1st and 15th) at 2 AM South African time
 *
 * Note: This function uses the admin instance initialized in the main index.js file
 */
exports.cleanupInactiveDocuments = (admin) => {
  return onSchedule(
    {
      schedule: "0 2 1,15 * *",
      timeZone: "Africa/Johannesburg"
    },
    async (event) => {
      logger.log("🧹 Starting cleanup of inactive documents...");

      const db = admin.firestore();
      const bucket = admin.storage().bucket();

      // Collections to check for inactive documents
      const collectionsToClean = ["Accommodation", "products"];

      // Calculate timestamp for 24 hours ago
      const twentyFourHoursAgo = new Date();
      twentyFourHoursAgo.setHours(twentyFourHoursAgo.getHours() - 24);
      const Timestamp = admin.firestore.Timestamp;
      const cutoffTimestamp = Timestamp.fromDate(twentyFourHoursAgo);

      let totalDeleted = 0;

      try {
        for (const collectionName of collectionsToClean) {
          logger.log(`Checking collection: ${collectionName}`);

          // Query for documents where status is 'inactive' and updatedAt is older than 24 hours
          const snapshot = await db
            .collection(collectionName)
            .where("status", "==", "inactive").get();

          if (snapshot.empty) {
            logger.log(`No inactive documents to delete in ${collectionName}`);
            continue;
          }

          logger.log(`Found ${snapshot.size} documents to delete in ${collectionName}`);

          // Delete in batches (Firestore limit is 500 operations per batch)
          const batchSize = 500;
          let batch = db.batch();
          let operationCount = 0;
          let deletedCount = 0;

          for (const doc of snapshot.docs) {
            const docId = doc.id;

            // If it's a product, delete associated images from storage
            if (collectionName === "products") {
              try {
                const folderPath = `products/${docId}/`;
                logger.log(`Deleting images in folder: ${folderPath}`);

                // List all files in the product's folder
                const [files] = await bucket.getFiles({ prefix: folderPath });

                if (files.length > 0) {
                  // Delete all files in the folder
                  await Promise.all(files.map(file => file.delete()));
                  logger.log(`✅ Deleted ${files.length} images for product ${docId}`);
                } else {
                  logger.log(`No images found for product ${docId}`);
                }
              } catch (storageError) {
                logger.error(`❌ Error deleting images for product ${docId}:`, storageError);
                // Continue with document deletion even if image deletion fails
              }
            }

            // Delete the Firestore document
            batch.delete(doc.ref);
            operationCount++;
            deletedCount++;

            // Commit batch when it reaches the limit
            if (operationCount === batchSize) {
              await batch.commit();
              logger.log(`Committed batch of ${batchSize} deletions`);
              batch = db.batch();
              operationCount = 0;
            }
          }

          // Commit any remaining operations
          if (operationCount > 0) {
            await batch.commit();
            logger.log(`Committed final batch of ${operationCount} deletions`);
          }

          logger.log(`✅ Deleted ${deletedCount} documents from ${collectionName}`);
          totalDeleted += deletedCount;
        }

        logger.log(`🎉 Cleanup completed. Total documents deleted: ${totalDeleted}`);
        return { success: true, totalDeleted };

      } catch (error) {
        logger.error("❌ Error during cleanup:", error);
        throw error;
      }
    }
  );
};