import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lindelany/Market/firebaseService/productModel.dart';

class ProductSet {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _reference = FirebaseFirestore.instance.collection(
    'products',
  );

  Future createProduct({
    required String sellerId,
    required String sellerName,
    required String productName,
    required int price,
    required String description,
    required String status,
    required String sellerUni,
    required bool isNew,
    required String category,
    required List<String> images,
  }) async {
    try {
      final Timestamp createdAt = Timestamp.now();

      DocumentReference docRef = await _reference.add({
        'sellerId': sellerId,
        'sellerName': sellerName,
        'productName': productName,
        'price': price,
        'description': description,
        'status': status,
        'sellerUni': sellerUni,
        'isNew': isNew,
        'category': category,
        'images': images,
        'createdAt': createdAt,
      });
      await docRef.update({'productId': docRef.id});
      return docRef.id;
    } catch (e) {
//      print('Error creating product: ${e.toString()}');
    }
  }

  //----------------------------------update product after upload-----------------

  Future<void> updateProductImages({
    required String productId,
    required List<String> images,
  }) async {
    try {
      await _reference.doc(productId).update({'images': images});
    } catch (e) {
//      print('Failed to update images: ${e.toString()}');
    }
  }

  //--------------------------listen for specific product-----------------------

  Stream<ProductModel> specificProduct(String documentId) {
    return _reference.doc(documentId).snapshots().map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      if (!doc.exists || doc.data() == null) {
        return ProductModel(
          productId: 'Using fall back',
          sellerId: '',
          sellerName: '',
          productName: '',
          price: 0,
          description: '',
          status: '',
          sellerUni: '',
          isNew: false,
          category: '',
          images: [],
          createdAt: Timestamp(0, 0),
        );
      }
      return ProductModel.fromDocument(doc);
    });
  }

  //-----------------------------Stream all products from a single user---------

  Stream<List<ProductModel>> getCurrentUserProducts() {
    try {
      final userId = _auth.currentUser?.uid;

      if (userId == null || userId.isEmpty) {
        return Stream.value([]);
      }

      return _reference
          .where('sellerId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((querySnapshot) {
            return querySnapshot.docs
                .map((doc) => ProductModel.fromDocument(doc))
                .toList();
          })
          .handleError((error) {
//            print('Error in getCurrentUserProducts: $error');
            return [];
          });
    } catch (e) {
//      print('Error setting up stream: $e');
      return Stream.value([]);
    }
  }

  //----------------------------stream to fetch 6 docs--------------------------

  Stream<List<ProductModel>> getSixProducts(
    String currentUserUni,
    String category, {
    String? excludeProductId,
  }) {
    return _reference
        .where('category', isEqualTo: category)
        .where('status', isEqualTo: 'active')
        .where('sellerUni', isEqualTo: currentUserUni)
        .limit(6)
        .snapshots()
        .map(
          (querySnapshot) => querySnapshot.docs
              .where(
                (doc) => excludeProductId == null || doc.id != excludeProductId,
              ) // Exclude current product
              .take(6) // Ensure we still get 6 products
              .map((doc) => ProductModel.fromDocument(doc))
              .toList(),
        );
  }

  //-----------------------Edit Product-----------------------------------------

  Future<void> updateProfile(
    String docId,
    int price,
    bool isNew,
    String uni,
    String category,
  ) async {
    try {
      await _reference.doc(docId).update({
        'price': price,
        'isNew': isNew,
        'sellerUni': uni,
        'category': category,
      });
    } catch (e) {}
  }

  //---------------------------Lazy load products---------------------------------

  DocumentSnapshot? _lastDoc; //Store the last doc.Fetching will start from here
  bool _hasMore = true; // if false, we reached the end of the database

  Future<List<ProductModel>> fetchProducts({
    int limit = 10,
    String? studentUniversity,
    String? category,
  }) async {
    final userId = _auth.currentUser!.uid ?? '';

    if (!_hasMore) return [];

    try {
      // First query - query the database for all available products
      Query query = _reference
          .where('status', isEqualTo: 'active')
          .where('sellerId', isNotEqualTo: userId);

      // Re-initialize query for specific uni
      if (studentUniversity != null && studentUniversity.trim().isNotEmpty) {
        final input = studentUniversity.trim();
        query = query.where('sellerUni', isEqualTo: input);
      }
      if (category != null && category.trim().isNotEmpty) {
        query = query.where('category', isEqualTo: category.trim());
      }

      // Order and plus 1 extra doc (11 docs)
      query = query.orderBy('createdAt', descending: true).limit(limit + 1);

      // Starting new query from last doc
      if (_lastDoc != null) {
        query = query.startAfterDocument(_lastDoc!);
      }

      // Snapshot or collection of Doc from the query
      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        _hasMore = false;
        return [];
      }

      // Collection is not empty and potentially has more docs (11 docs)
      if (snapshot.docs.length > limit) {
        _hasMore = true;
        // SAFE: Use limit-1 only if it exists
        _lastDoc = snapshot.docs[limit - 1];

        // Return the docs as a list (first 'limit' number of docs)
        return snapshot.docs
            .take(limit)
            .map((doc) => ProductModel.fromDocument(doc))
            .toList();
      } else {
        // We have exactly limit number of docs or less
        _hasMore = false;

        _lastDoc = snapshot.docs.last;
        return snapshot.docs
            .map((doc) => ProductModel.fromDocument(doc))
            .toList();
      }
    } catch (e) {
//      print('Error in fetchProducts: $e');
      // Reset pagination on error to prevent stuck state
      resetPagination();
      return [];
    }
  }

  //--------------------------------------clear lazy loading----------------------
  void resetPagination() {
    _lastDoc = null;
    _hasMore = true;
  }

  //Exposing the has more flag so other parts of the code can know
  bool get hasMore => _hasMore;
}
