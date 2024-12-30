import 'package:flutter/material.dart';

class ObjectDisplay extends StatefulWidget {
  final String objectName;

  const ObjectDisplay({
    super.key,
    required this.objectName,
  });

  @override
  State<ObjectDisplay> createState() => _ObjectDisplayState();
}

class _ObjectDisplayState extends State<ObjectDisplay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(ObjectDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.objectName != oldWidget.objectName) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getImagePath() {
    // Extract color and object type from the objectName
    final isRed = widget.objectName.toLowerCase().contains('красный');
    final isGreen = widget.objectName.toLowerCase().contains('зеленый');
    
    // Map object names to image paths
    final objectMap = {
      'ШНУРОК': 'shnurok',
      'ЧЕРВЯК': 'poloska',
      'РЕЗИНКА': 'rezinka',
      'НАПЕРСТОК': 'naperstok',
      'ВИЛКА': 'vilka',
      'КОВИД': 'covid_big',
      'БУСИНА': 'busina',
      'ПЕРЧИК': 'perchik',
      'ПРИЩЕПКА': 'prischepka',
      'ГОЛОВОЛОМКА': 'golovolomka',
      'ШАРИК': 'sharik',
    };

    // Find the matching object
    String? objectKey = objectMap.keys.firstWhere(
      (key) => widget.objectName.toUpperCase().contains(key),
      orElse: () => '',
    );
    
    if (objectKey.isEmpty) return '';
    
    String baseObject = objectMap[objectKey]!;
    String color = isRed ? 'red' : (isGreen ? 'green' : '');
    
    return 'assets/images/${color}/${baseObject}.jpg';
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final objectSize = screenSize.height * 0.4;
    final imagePath = _getImagePath();

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: objectSize,
        height: objectSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: imagePath.isNotEmpty
              ? DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: imagePath.isEmpty
            ? Center(
                child: Text(
                  widget.objectName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}