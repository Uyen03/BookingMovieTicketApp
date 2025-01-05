import 'package:bookingmovieticket/models/ad_slider_model.dart';
import 'package:bookingmovieticket/models/crew_cast_model.dart';
import 'package:bookingmovieticket/models/event_model.dart';
import 'package:bookingmovieticket/models/menu_model.dart';
import 'package:bookingmovieticket/models/movie_model.dart';
import 'package:bookingmovieticket/models/offer_model.dart';
import 'package:bookingmovieticket/models/theatre_model.dart';
import 'package:bookingmovieticket/utils/mytheme.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../utils/constants.dart';

List<AdSliderModel> sliderData = [
  AdSliderModel(
      url: "assets/slider_banner.png", redirectUrl: Constants.baseApiUrl),
  AdSliderModel(
      url: "assets/slider_banner.png", redirectUrl: Constants.baseApiUrl),
  AdSliderModel(
      url: "assets/slider_banner.png", redirectUrl: Constants.baseApiUrl),
];

List<MenuModel> menus = [
  MenuModel(name: "Movies", asset: "assets/icons/film.svg"),
  MenuModel(name: "Events", asset: "assets/icons/spotlights.svg"),
  MenuModel(name: "Plays", asset: "assets/icons/theater_masks.svg"),
  MenuModel(name: "Sports", asset: "assets/icons/running.svg"),
  MenuModel(name: "Activity", asset: "assets/icons/flag.svg"),
  MenuModel(name: "Monum", asset: "assets/icons/pyramid.svg"),
];
// List<MovieModel> movies = [
//   MovieModel(
//     title: "Bigil",
//     description: "description",
//     actors: ["actor a", "actor b"],
//     like: 84,
//     bannerUrl: "assets/movies/movie1.png",
//   ),
//   MovieModel(
//     title: "Kaithi",
//     description: "description",
//     actors: ["actor a", "actor b"],
//     like: 84,
//     bannerUrl: "assets/movies/movie2.png",
//   ),
//   MovieModel(
//     title: "Asuran",
//     description: "description",
//     actors: ["actor a", "actor b"],
//     like: 84,
//     bannerUrl: "assets/movies/movie3.png",
//   ),
//   MovieModel(
//     title: "Sarkar",
//     description: "description",
//     actors: ["actor a", "actor b"],
//     like: 84,
//     bannerUrl: "assets/movies/movie4.png",
//   ),
// ];
List<EventModel> events = [
  EventModel(
    title: "Happy Halloween 2K19",
    description: "Music show",
    date: "date",
    bannerUrl: "assets/events/event1.png",
  ),
  EventModel(
    title: "Music DJ king monger Sert...",
    description: "Music show",
    date: "date",
    bannerUrl: "assets/events/event2.png",
  ),
  EventModel(
    title: "Summer sounds festiva..",
    description: "Comedy show",
    date: "date",
    bannerUrl: "assets/events/event3.png",
  ),
  EventModel(
    title: "Happy Halloween 2K19",
    description: "Music show",
    bannerUrl: "assets/events/event4.png",
    date: "date",
  ),
];

List<EventModel> plays = [
  EventModel(
    title: "Alex in wonderland",
    description: "Comedy Show",
    date: "date",
    bannerUrl: "assets/plays/play1.png",
  ),
  EventModel(
    title: "Marry poppins puffet show",
    description: "Music Show",
    date: "date",
    bannerUrl: "assets/plays/play2.png",
  ),
  EventModel(
    title: "Patrimandram special dewali",
    description: "Dibet Show",
    date: "date",
    bannerUrl: "assets/plays/play3.png",
  ),
  EventModel(
    title: "Happy Halloween 2K19",
    description: "Music Show",
    bannerUrl: "assets/plays/play4.png",
    date: "date",
  ),
];

List<OfferModel> offers = [
  OfferModel(
    title: "Wait ! Grab FREE reward",
    description: "Book your seats and tap on the reward box to claim it.",
    expiry: DateTime(2024, 4, 15, 12),
    startTime: DateTime(2024, 3, 15, 12),
    discount: 100,
    color: MyTheme.redTextColor,
    gradientColor: MyTheme.redGiftGradientColors,
  ),
  OfferModel(
    title: "Wait ! Grab FREE reward",
    description: "Book your seats and tap on the reward box to claim it.",
    expiry: DateTime(2024, 4, 15, 12),
    startTime: DateTime(2024, 3, 15, 12),
    discount: 100,
    color: MyTheme.greenTextColor,
    gradientColor: MyTheme.greenGiftGradientColors,
    icon: "gift_green.svg",
  ),
];

List<String> cities = [
  "Thành phố Thủ Đức",
  "Quận 1",
  "Quận 2",
  "Quận 3",
  "Quận 7",
];

List<String> screens = [
  "3D",
  "2D",
];

List<CrewCastModel> crewCast = [
  CrewCastModel(
    movieId: "123",
    castId: "123",
    name: "Chadwick",
    image: "assets/actors/chadwick.png",
  ),
  CrewCastModel(
    movieId: "123",
    castId: "123",
    name: "Letitia Wright",
    image: "assets/actors/LetitiaWright.png",
  ),
  CrewCastModel(
    movieId: "123",
    castId: "123",
    name: "B. Jordan",
    image: "assets/actors/b_jordan.png",
  ),
  CrewCastModel(
    movieId: "123",
    castId: "123",
    name: "Lupita Nyong",
    image: "assets/actors/lupita_nyong.png",
  ),
];
// List<Theatre> theatres = [
//   Theatre(
//     id: "1",
//     name: "Arasan Cinemas A/C 2K Dolby",
//     coordinates: LatLng(10.8765, 78.7654),
//     facilities: ["Parking", "Snacks", "Dolby Atmos"],
//     fullAddress: "123 Main Road, Chennai, India",
//     timings: ["10:00 AM", "1:00 PM", "5:00 PM", "9:00 PM"],
//     availableScreens: ["IMAX", "2D"],
//   ),
//   Theatre(
//     id: "2",
//     name: "INOX - Prozone Mall",
//     coordinates: LatLng(11.2345, 79.1234),
//     facilities: ["Snacks", "Parking", "VIP Lounge"],
//     fullAddress: "Prozone Mall, Coimbatore, India",
//     timings: ["9:00 AM", "12:00 PM", "3:00 PM", "6:00 PM"],
//     availableScreens: ["3D", "4K"],
//   ),
//   Theatre(
//     id: "3",
//     name: "Karpagam Theatres - 4K Dolby Atmos",
//     coordinates: LatLng(10.8901, 78.4567),
//     facilities: ["4K Screen", "Dolby Atmos", "Snacks"],
//     fullAddress: "456 Karpagam Road, Coimbatore, India",
//     timings: ["10:30 AM", "2:30 PM", "6:30 PM", "9:30 PM"],
//     availableScreens: ["IMAX", "2D", "3D"],
//   ),
//   Theatre(
//     id: "4",
//     name: "KG Theatres - 4K",
//     coordinates: LatLng(10.9876, 78.6543),
//     facilities: ["Parking", "4K Screen", "Dolby Surround"],
//     fullAddress: "789 KG Road, Madurai, India",
//     timings: ["11:00 AM", "3:00 PM", "7:00 PM", "10:00 PM"],
//     availableScreens: ["2D", "3D"],
//   ),
// ];
List<String> facilityAsset = [
  "assets/icons/cancel.svg",
  "assets/icons/parking.svg",
  "assets/icons/cutlery.svg",
  "assets/icons/rocking_horse.svg",
];
