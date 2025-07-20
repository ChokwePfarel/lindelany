import 'package:flutter/material.dart';
import '../../constants/scale.dart' show SizeConfig;
import '../widgets/colums.dart';


class drawerTile extends StatelessWidget {
  final String text;
  final Widget lead;
  final Widget navigate;
  const drawerTile({super.key, required this.text, required this.lead, required this.navigate});

  @override
  Widget build(BuildContext context) {
    return customCard1(
        heightt: SizeConfig.screenHeight*0.070,
        colorr: Colors.grey,
        isPadding: EdgeInsets.zero,
        widgett: ListTile(
        leading: lead,
        title: Text(text,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white,fontWeight: FontWeight.bold),),
        onTap: (){
          Navigator.push(context,
              MaterialPageRoute(builder: (context)=> navigate ));
        },
      ),
    );
  }
}
