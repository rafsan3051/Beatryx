import 'package:flutter/material.dart';

abstract class PlayerUI {
  Widget buildHome(BuildContext context);
  Widget buildNowPlaying(BuildContext context);
  Widget buildMiniPlayer(BuildContext context);
}
