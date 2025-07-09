/*import 'package:flutter/material.dart';
import '../utility/utility_class.dart';
import 'Navigation.dart';

class docCheck extends StatefulWidget {

  final Widget onTrue;
  final Widget onFalse;
  final bool useNavigation;

  const docCheck({super.key, required this.onTrue, required this.onFalse, this.useNavigation = true});

  @override
  State<docCheck> createState() => _docCheckState();
}


class _docCheckState extends State<docCheck> {



  final future = CustomNavigation().checkForDoc('Users','City');

  @override
  Widget build(BuildContext context) {



    return FutureBuilder<bool>(
        future: future,
        builder:(context, snapshot){
      if(AsyncUtils.isLoadingOrError(snapshot)){
        return AsyncUtils.BuildIsloadingOrError(snapshot);
      }


        bool hasProvidedInfon = snapshot.data ?? false;

        if(widget.useNavigation){
          WidgetsBinding.instance.addPostFrameCallback((_){ ///ensures navigation happens after the build phase,
            /// preventing errors.
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) =>  hasProvidedInfon ? widget.onTrue : widget.onFalse ));
          });
          return const Center(child: CircularProgressIndicator(),); // Return loading indicator while navigating
        }
        //SHOW SCREENS
        return hasProvidedInfon ? widget.onTrue : widget.onFalse;

    });
  }
}*/
