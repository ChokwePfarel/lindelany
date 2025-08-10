import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart' show Provider, ReadContext;
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import '../../Constants/Constants.dart';
import '../../constants/scale.dart';
import '../../firebase_Set/setStudent.dart';
import '../../firebase_Set/user.dart';
import '../../classes/user_model.dart';
import '../../user_interface/Common/Accommodations.dart';
import '../../utility/utility_class.dart';
import '../create/create_broadcast.dart';
import '../from_firebase/broadcast.dart';
import '../broadcast_vehicle_model.dart';
import '../widgets/for_user_broadcast.dart';

class myBroadcasts extends StatefulWidget {
  const myBroadcasts({super.key});

  @override
  State<myBroadcasts> createState() => _myBroadcastsState();
}

class _myBroadcastsState extends State<myBroadcasts> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      Provider.of<StudentProvider>(
        context as BuildContext,
        listen: false,
      ).currentStudent();
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final streamBroadcast = broadcast().userBroadcast;
    final streamUser = UserProvider().currentUserData();
    final studentUni = context.read<StudentProvider>().currentUser?.uni ?? '';

    final combinedStream =
        Rx.combineLatest2<
          List<BroadcastModel>,
          UserModel,
          Tuple2<List<BroadcastModel>, UserModel>
        >(
          streamBroadcast,
          streamUser,
          (broadcastt, user) => Tuple2(broadcastt, user),
        );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: blue900,
        title: Text(
          'My broadcasts',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Accomodations()),
              );
            },
            icon: Icon(Icons.home_filled, color: Colors.white),
          ),
        ],
      ),
      body: StreamBuilder<Tuple2<List<BroadcastModel>, UserModel>>(
        stream: combinedStream,
        builder: (context, snapshot) {
          // Handle connection state
          if (AsyncUtils.isLoadingOrError(snapshot)) {
            return AsyncUtils.BuildIsloadingOrError(snapshot);
          }
          // At this point, we have data (even if empty)
          final broadcasts = snapshot.data?.item1 ?? [];
          final user = snapshot.data?.item2;

          // If user is null (shouldn't happen if authenticated)
          if (user == null) {
            return const Center(child: Text('User not found'));
          }

          return Stack(
            children: [
              ListView.builder(
                itemCount: broadcasts.length,
                itemBuilder: (context, index) {
                  final broadcast = broadcasts[index];

                  return Padding(
                    padding: EdgeInsetsGeometry.only(bottom: 10),
                    child: CustomUserBroadCard(broadcast: broadcast),
                  );
                },
              ),
              Positioned(
                right: 20,
                bottom: 20,
                child: FloatingActionButton(
                  backgroundColor: Colors.blue.shade900,
                  onPressed: () {
                    // Get the user from snapshot
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CreateBroadcast(user: user, studentUni: studentUni),
                      ),
                    );
                  },
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
