import 'package:flutter/material.dart';
import 'package:lindelany/Constants/Constants.dart';
import 'package:lindelany/constants/scale.dart';
import 'package:lindelany/custom_made/widgets/colums.dart';
import 'package:lindelany/static/delete_account.dart';

import '../../signIn&out/authService.dart';
import '../../signIn&out/logIn.dart';
import '../../static/snackbar.dart';

class Settingss extends StatelessWidget {
  const Settingss({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final heading = theme.bodyMedium!.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );

    final body = theme.bodySmall!.copyWith(color: Colors.white);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: blue900,
        title: Text(
          'Settings',
          style: theme.bodyLarge!.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manage Account',
                style: theme.headlineMedium!.copyWith(
                  color: blue900,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: SizeConfig.screenHeight * 0.15),

              customCard1(
                colorr: blue900,
                widgett: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sign out', style: heading),

                    SizedBox(height: SizeConfig.screenHeight * 0.015),

                    Text('Log out you current Profile', style: body),

                    SizedBox(height: SizeConfig.screenHeight * 0.010),

                    customCard1(
                      colorr: Colors.red.shade900,
                      widgett: TextButton(
                        onPressed: () {
                          showDialog(context: context,
                              builder: (context) => confirmDialog(
                                  title: 'Log out',
                                  message: 'Are you sure you want to log out ?',
                                  onConfirm: () async {
                                    await AuthService().signOut();

                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (context) => LoginPage()),
                                          (route) => false,
                                    );
                                  }));
                        },
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.white, size: 20),

                            Text('Log Out', style: heading),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: SizeConfig.screenHeight * 0.020),

              customCard1(
                colorr: blue900,
                widgett: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Delete Account', style: heading),
                    SizedBox(height: SizeConfig.screenHeight * 0.015),

                    Text(
                      'If you wish to delete your profile, click the button below.',
                      style: body,
                    ),

                    SizedBox(height: SizeConfig.screenHeight * 0.010),

                    customCard1(
                      colorr: Colors.red.shade900,
                      widgett: TextButton(
                        onPressed: () {
                          Delete_account.openDeleteAccountPage();
                        },
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.white, size: 20),
                            Text('Delete Account', style: heading),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
