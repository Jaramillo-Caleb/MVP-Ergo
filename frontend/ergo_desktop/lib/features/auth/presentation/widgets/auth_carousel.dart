import 'dart:async';
import 'package:flutter/material.dart';

class AuthCarousel extends StatefulWidget {
  const AuthCarousel({super.key});

  @override
  State<AuthCarousel> createState() => _AuthCarouselState();
}

class _AuthCarouselState extends State<AuthCarousel> {
  final List<Map<String, String>> _carruselData = const [
    {
      "title": "Tu Asistente Ergonómico Personal",
      "description": "Corrige tu postura en tiempo real mediante visión artificial.",
      "image": "assets/carrusel/carrusel_03.png"
    },
    {
      "title": "Privacidad Total con Edge Computing",
      "description": "Proceso de IA 100% local para máxima seguridad.",
      "image": "assets/carrusel/carrusel_01.png"
    },
    {
      "title": "Productividad Sin Fragmentación",
      "description": "Optimiza tu flujo de trabajo con temporizadores Pomodoro.",
      "image": "assets/carrusel/carrusel_02.png"
    },
  ];

  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (var item in _carruselData) {
      precacheImage(AssetImage(item["image"]!), context);
    }
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _carruselData.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1000),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: _CarouselItem(
              key: ValueKey<int>(_currentIndex), // Importante para que detecte el cambio
              data: _carruselData[_currentIndex],
            ),
          ),
          
          Positioned(
            bottom: 40,
            left: 60,
            child: Row(
              children: List.generate(
                _carruselData.length,
                (index) => _buildDot(index == _currentIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      width: isActive ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _CarouselItem extends StatelessWidget {
  final Map<String, String> data;
  const _CarouselItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          data["image"]!,
          fit: BoxFit.cover,
          cacheWidth: (size.width * MediaQuery.of(context).devicePixelRatio).toInt(),
          filterQuality: FilterQuality.low, // 'low' es más rápido para animaciones
        ),
        
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black87,
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data["title"]!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Text(
                  data["description"]!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 18,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ],
    );
  }
}