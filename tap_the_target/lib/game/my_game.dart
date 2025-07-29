
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart'; 
import 'package:flutter/material.dart';
import 'dart:math';



class MyGame extends FlameGame with HasTappables {
  @override
  Future<void> onLoad() async {
    add(Target());
  }
}

class Target extends SpriteComponent with Tappable {
  final _random = Random();

  Target() : super(size: Vector2.all(64));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('target.png');
    position = Vector2(_random.nextDouble() * 300, _random.nextDouble() * 500);
  }

  @override
  bool onTapDown(_) {
    removeFromParent(); // remove when tapped
    gameRef.add(Target()); // add a new one
    return true;
  }
}
