import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import '../../firebase_Set/user.dart';
import '../../firebase_Set/setStudent.dart';
import '../../classes/student_model.dart';
import '../../classes/user_model.dart';

class currentUserStreamWidget extends StatelessWidget {
  final Function(BuildContext, UserModel, StudentModel) builder;


  const currentUserStreamWidget({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final stream1 = UserProvider().currentUserData(); // User Info stream
    final stream2 = StudentProvider().currentStudentDoc(); // Student Form stream

// Combine the three streams using Rx.combineLatest3
    final combinedStream = Rx.combineLatest2<UserModel,StudentModel,
        Tuple2<UserModel, StudentModel>>(
      stream1, stream2,
          (userInfo, userForm) => Tuple2(userInfo, userForm),
    );

    return StreamBuilder<Tuple2<UserModel, StudentModel>>(
        stream: combinedStream,
        builder: (context, snapshot) {
      // Handle loading state
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      // Handle error state
      if (snapshot.hasError) {
        print(snapshot.stackTrace);
        return Center(child: Text('An error occurred: ${snapshot.error}'));
      }

      // Handle case where no data is available
      if (!snapshot.hasData || snapshot.data == null) {
        return const Center(child: Text('No data available.'));
      }

      // Safely access the data (since we already checked that data exists)
      final user = snapshot.data!.item1;
      final student = snapshot.data!.item2;

      return builder(context, user, student);}
    );
  }
}
