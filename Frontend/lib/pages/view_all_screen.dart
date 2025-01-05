import 'package:bookingmovieticket/pages/details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:bookingmovieticket/controllers/common_controller.dart';
import 'package:bookingmovieticket/controllers/location_controller.dart';
import 'package:bookingmovieticket/controllers/movie_controller.dart';
import 'package:bookingmovieticket/widgets/item_block.dart';
import '../models/user_model.dart'; // Import model UserModel

class ViewAllScreen extends StatelessWidget {
  const ViewAllScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MovieController movieController = Get.find<MovieController>();
    final UserModel user =
        Get.find<UserModel>(); // Get thông tin người dùng từ GetX

    return WillPopScope(
      onWillPop: () {
        CommonController.instance.tabController.animateTo(0);
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Movies in ${LocationController.instance.city}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: MySearchDelegate(
                    list: movieController.movies,
                  ),
                );
              },
              icon: SvgPicture.asset("assets/icons/search.svg"),
            ),
          ],
        ),
        body: Obx(() {
          if (movieController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (movieController.movies.isEmpty) {
            return const Center(
              child: Text("No movies available."),
            );
          }

          return GridView.builder(
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (_, index) {
              return ItemBlock(
                model: movieController.movies[index],
                height: 180,
                width: 150,
                onTap: (model) {
                  // Truyền thông tin người dùng vào DetailsScreen
                  Get.to(() => DetailsScreen(user: user),
                      arguments: [model, index]);
                },
              );
            },
            itemCount: movieController.movies.length,
          );
        }),
      ),
    );
  }
}

// Lớp tìm kiếm
class MySearchDelegate extends SearchDelegate<String> {
  final List<dynamic> list;

  MySearchDelegate({required this.list});

  resultWidget(dynamic model) {
    return ItemBlock(
      model: model,
      height: 180,
      width: 150,
      onTap: (model) {},
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null.toString());
      },
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_close,
        progress: transitionAnimation,
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final suggestionList = list
        .where((element) =>
            element.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (_, index) {
        return resultWidget(suggestionList[index]);
      },
      itemCount: suggestionList.length,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? list
        : list
            .where((element) =>
                element.title.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (_, index) {
        return resultWidget(suggestionList[index]);
      },
      itemCount: suggestionList.length,
    );
  }
}
