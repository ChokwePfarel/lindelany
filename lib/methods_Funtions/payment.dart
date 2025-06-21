/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class PaymentPage extends StatefulWidget {
  final double amount;
  final String userId;
  final String plan;

  const PaymentPage({super.key, required this.amount, required this.userId, required this.plan});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {


  //--------------------------------------------------------------------------------------------------------------------------------------
  //UPDATE USER AND CREATE A NEW DOC OF PAYMENT
  Future<void> updateUserPaymentStatus(String userId, String paymentId) async {

    final userDoc = _reference.collection('Users');

    await userDoc.doc(userId).update({
      "hasPaid": true,
      "paymentHistory": FieldValue.arrayUnion([paymentId])
    });

    final paymentDoc = _reference.collection('payments');
    await paymentDoc.doc(paymentId).set({
      "userId": userId,
      "amount": 500, //REPLACE
      "timestamp": DateTime.now().toIso8601String(),
      "status": "success"
    }
    );
  }

    //--------------------------------------------------------------------------

    late WebViewController _webViewController;

    // This HTML content uses Yoco Web SDK to handle the payment modal
    String generateYocoHTML(double amount) {
      return """
    <!DOCTYPE html>
    <html>
    <head>
      <script src="https://js.yoco.com/sdk/v1/yoco-sdk-web.js"></script>
      <script>
        function launchYoco() {
          const yoco = new window.YocoSDK({
            publicKey: 'YOUR_PUBLIC_KEY' // PUBLIC KEY
          });

          yoco.showPopup({
            amountInCents: ${amount * 100}, // Amount in cents
            currency: 'ZAR',
            name: 'Accommodation Ad Payment',
            description: 'Payment for promoting your accommodation.',
            callback: function (result) {
              if (result.error) {
                window.flutter_inappwebview.callHandler('paymentStatus', 'failure');
              } else {
                window.flutter_inappwebview.callHandler('paymentStatus', 'success', result.id);
              }
            },
          });
        }
      </script>
    </head>
    <body onload="launchYoco()">
    </body>
    </html>
    """;
    }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Payments'),
      ),

      body: WebView(
        initialUrl: Uri.dataFromString(
          generateYocoHTML(widget.amount),
          mimeType: 'text/html',
        ).toString(),
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        javascriptChannels: <JavascriptChannel>{
          JavascriptChannel(
            name: 'paymentStatus',
            onMessageReceived: (message) async {
              String userId = _auth.currentUser!.uid;
              // Handle payment status
              if (message.message == 'success'){
//WHAT WILL HAPPEN IF I REMOVE AWAITV AND SYNC
               // String paymentId = message.data ; // Assume this holds the paymentId (result.id)

                //await updateUserPaymentStatus(_userId, paymentId);



                _create();
                Navigator.pop(context, "Payment Successful");

              } else {
                Navigator.pop(context, "Payment Failed");
              }
            },
          ),
        },
      ),
    );

  }

  //CREATE ACCOMMODATION

  final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _reference = FirebaseFirestore.instance;


//------------------------------------------------------------------------------------------------------------------------------------------------------
 *//* Future<void> _create() async {

    final _userId = FirebaseAuth.instance.currentUser?.uid;

    try{
      await LandLord(uid: _userId).createListing(_userId!,_accommodationName, _location, _nsfas, _isWifi, _isParking, _numbers, _about, _double, _single, _full,
          _selectedProvince, _selectedGenders, _selectedType, _available, _aboutPayment, _laundry, _tv, _security, _transport, _kitchen, _bed, _shower,[]);
      Navigator.pop(context);
    }catch (e){ print(e.toString());
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Created")));}
  }*//*

  void _create() async {
  }

  final String _accommodationName = '';final String _location= '';final String _double = '';final String _single='';final String _numbers = '';final String _about = '';
  final bool _nsfas = false;final bool _isWifi = false;final bool _isParking = false;final bool _full = false;
  final bool _laundry = false;final bool _tv = false;final bool _security = false;final bool _transport = false;final bool _kitchen = false;final bool _bed = false;final bool _shower = false;
  final String _selectedProvince = '';final String _selectedGenders ='';final String _selectedType = '';final String _available = ''; final String _aboutPayment = '';

}*/

