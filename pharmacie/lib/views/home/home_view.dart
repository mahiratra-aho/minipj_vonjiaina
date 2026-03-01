import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/routes/app_routes.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
class _C {
  static const primary = Color(0xFF5B21B6);
  static const primaryDk = Color(0xFF3B0E8C);
  static const primaryLt = Color(0xFFEDE9FE);
  static const accent = Color(0xFF7C3AED);
  static const white = Colors.white;
  static const ink = Color(0xFF0F0A1E);
  static const muted = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
}

// ─────────────────────────────────────────────
//  TYPOGRAPHY HELPERS
// ─────────────────────────────────────────────
TextStyle _display(
  double size, {
  Color color = _C.ink,
  FontWeight fw = FontWeight.w800,
}) => GoogleFonts.sora(
  fontSize: size,
  fontWeight: fw,
  color: color,
  height: 1.15,
);

TextStyle _body(
  double size, {
  Color color = _C.muted,
  FontWeight fw = FontWeight.w400,
}) => GoogleFonts.inter(
  fontSize: size,
  fontWeight: fw,
  color: color,
  height: 1.6,
);

// ─────────────────────────────────────────────
//  HOME VIEW
// ─────────────────────────────────────────────
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _scrollCtrl = ScrollController();
  bool _navScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      final scrolled = _scrollCtrl.offset > 20;
      if (scrolled != _navScrolled) setState(() => _navScrolled = scrolled);
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.white,
      body: Stack(
        children: [
          // ── Scrollable content ──
          SingleChildScrollView(
            controller: _scrollCtrl,
            child: Column(
              children: [
                const SizedBox(height: 72), // nav height offset
                const _HeroSection(),
                const _AdvantagesSection(),
                const _HowItWorksSection(),
                const _TestimonialSection(),
                const _CtaSection(),
                const _FooterSection(),
              ],
            ),
          ),
          // ── Sticky nav on top ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TopNavBar(scrolled: _navScrolled),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TOP NAV BAR
// ─────────────────────────────────────────────
class _TopNavBar extends StatelessWidget {
  final bool scrolled;
  const _TopNavBar({required this.scrolled});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 72,
      decoration: BoxDecoration(
        color: _C.white,
        border: Border(
          bottom: BorderSide(color: scrolled ? _C.border : Colors.transparent),
        ),
        boxShadow: scrolled
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        children: [
          // Logo
          Row(
            children: [Text('Vonjiaina', style: _display(20, color: _C.ink))],
          ),

          const Spacer(),

          // CTA button
          _PrimaryButton(
            label: 'Espace Pharmacien',
            onTap: () => context.go(AppRoutes.login),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HERO SECTION
// ─────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Container(
      color: _C.white,
      padding: EdgeInsets.symmetric(
        horizontal: w > 1200 ? 96 : 48,
        vertical: 72,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Left: text ──
          Expanded(
            flex: 55,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _C.primaryLt,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: _C.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'Plateforme dédiée aux pharmacies',
                        style: _body(
                          12,
                          color: _C.primary,
                          fw: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Headline
                Text(
                  'Rejoignez le réseau Vonjiaina',
                  style: _display(w > 1100 ? 52 : 40, color: _C.ink),
                ),
                const SizedBox(height: 20),

                // Subtext
                Text(
                  'Augmentez votre visibilité et gérez votre stock en\ntemps réel pour mieux servir vos patients.',
                  style: _body(17, color: _C.muted),
                ),
                const SizedBox(height: 36),

                // Buttons
                Row(
                  children: [
                    _PrimaryButton(
                      label: 'SE CONNECTER',
                      onTap: () => context.go(AppRoutes.login),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 16,
                      ),
                      fontSize: 14,
                    ),
                    const SizedBox(width: 14),
                    _OutlineButton(
                      label: "S'INSCRIRE",
                      onTap: () => context.go(AppRoutes.registerStep1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 56),

          // ── Right: pharmacy illustration ──
          Expanded(flex: 45, child: _HeroImage()),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background gradient simulating pharmacy shelves
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFD4C8F0),
                    Color(0xFFF0ECF8),
                    Color(0xFFE8E0F4),
                  ],
                ),
              ),
            ),
            // Decorative shelves
            CustomPaint(painter: _ShelvePainter()),
            // Centered pharmacist icon area
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _C.primary.withValues(alpha: 0.2),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_pharmacy_rounded,
                      size: 48,
                      color: _C.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified, color: _C.primary, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Pharmacie connectée',
                          style: _body(
                            13,
                            color: _C.primary,
                            fw: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Floating badge - stock
            Positioned(
              top: 24,
              right: 24,
              child: _FloatingBadge(
                icon: Icons.inventory_2_rounded,
                label: '1 240',
                sub: 'Médicaments gérés',
                color: _C.primary,
              ),
            ),
            // Floating badge - patients
            Positioned(
              bottom: 28,
              left: 28,
              child: _FloatingBadge(
                icon: Icons.people_alt_rounded,
                label: '+320',
                sub: 'Patients ce mois',
                color: _C.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  const _FloatingBadge({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: _display(15, color: _C.ink)),
              Text(sub, style: _body(11, color: _C.muted)),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom painter for shelves background effect
class _ShelvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB8A8E0).withValues(alpha: 0.35)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Small medicine box shapes on shelves
    final boxPaint = Paint()..style = PaintingStyle.fill;
    final colors = [
      const Color(0xFF9B7FD4),
      const Color(0xFF7B5BC4),
      const Color(0xFFB99EE0),
    ];
    final positions = [
      [0.1, 0.08, 0.06, 0.12],
      [0.22, 0.08, 0.07, 0.11],
      [0.38, 0.08, 0.05, 0.13],
      [0.55, 0.08, 0.08, 0.10],
      [0.70, 0.08, 0.06, 0.12],
      [0.83, 0.08, 0.07, 0.11],
      [0.08, 0.33, 0.06, 0.11],
      [0.20, 0.33, 0.08, 0.12],
      [0.34, 0.33, 0.05, 0.10],
      [0.50, 0.33, 0.07, 0.13],
      [0.65, 0.33, 0.06, 0.11],
      [0.78, 0.33, 0.08, 0.12],
    ];

    for (int i = 0; i < positions.length; i++) {
      final p = positions[i];
      boxPaint.color = colors[i % colors.length].withValues(alpha: 0.4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * p[0],
            size.height * p[1],
            size.width * p[2],
            size.height * p[3],
          ),
          const Radius.circular(3),
        ),
        boxPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────
//  NOS AVANTAGES
// ─────────────────────────────────────────────
class _AdvantagesSection extends StatelessWidget {
  const _AdvantagesSection();

  static const _items = [
    (
      Icons.star_rounded,
      'Visibilité',
      'Attirez plus de patients vers votre officine grâce à notre annuaire géolocalisé et intelligent.',
    ),
    (
      Icons.bolt_rounded,
      'Efficacité',
      'Optimisez vos opérations quotidiennes avec des outils automatisés conçus pour les pharmaciens.',
    ),
    (
      Icons.bar_chart_rounded,
      'Contrôle',
      'Suivez vos stocks et performances en temps réel avec des tableaux de bord intuitifs et précis.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F6FB),
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 80),
      child: Column(
        children: [
          // Section header
          Text('Nos Avantages', style: _display(36, color: _C.ink)),
          const SizedBox(height: 14),
          SizedBox(
            width: 460,
            child: Text(
              'Découvrez comment notre plateforme transforme votre gestion quotidienne et votre relation patient.',
              textAlign: TextAlign.center,
              style: _body(16),
            ),
          ),
          const SizedBox(height: 52),

          // Cards row
          Row(
            children: _items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 0 : 16),
                  child: _AdvantageCard(
                    icon: item.$1,
                    title: item.$2,
                    desc: item.$3,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _AdvantageCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _AdvantageCard({
    required this.icon,
    required this.title,
    required this.desc,
  });
  @override
  State<_AdvantageCard> createState() => _AdvantageCardState();
}

class _AdvantageCardState extends State<_AdvantageCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hovered ? _C.primary.withValues(alpha: 0.3) : _C.border,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: _C.primary.withValues(alpha: 0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _hovered ? _C.primary : _C.primaryLt,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                widget.icon,
                color: _hovered ? _C.white : _C.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.title,
              style: _display(18, color: _C.ink, fw: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(widget.desc, style: _body(14)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  COMMENT ÇA MARCHE
// ─────────────────────────────────────────────
class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection();

  static const _steps = [
    (
      '1',
      'Inscription',
      'Créez votre compte professionnel en quelques minutes seulement.',
    ),
    (
      '2',
      'Gestion',
      'Configurez votre catalogue et synchronisez vos stocks facilement.',
    ),
    (
      '3',
      'Visibilité',
      'Devenez immédiatement visible auprès de milliers de patients locaux.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _C.white,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 80),
      child: Column(
        children: [
          Text('Comment ça marche ?', style: _display(36, color: _C.ink)),
          const SizedBox(height: 56),

          // Steps row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _steps.asMap().entries.map((e) {
              final i = e.key;
              final step = e.value;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 0 : 16),
                  child: _StepCard(
                    num: step.$1,
                    title: step.$2,
                    desc: step.$3,
                    isLast: i == _steps.length - 1,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatefulWidget {
  final String num;
  final String title;
  final String desc;
  final bool isLast;
  const _StepCard({
    required this.num,
    required this.title,
    required this.desc,
    this.isLast = false,
  });
  @override
  State<_StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<_StepCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Column(
        children: [
          // Number circle with connector line
          Row(
            children: [
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Line to next step
                      if (!widget.isLast)
                        Positioned(
                          left: 56,
                          right: 0,
                          child: Container(height: 2, color: _C.primaryLt),
                        ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _hovered ? _C.primary : _C.primary,
                          shape: BoxShape.circle,
                          boxShadow: _hovered
                              ? [
                                  BoxShadow(
                                    color: _C.primary.withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            widget.num,
                            style: _display(
                              20,
                              color: _C.white,
                              fw: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            widget.title,
            style: _display(17, color: _C.ink, fw: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(widget.desc, style: _body(14), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TESTIMONIAL
// ─────────────────────────────────────────────
class _TestimonialSection extends StatelessWidget {
  const _TestimonialSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F6FB),
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: _C.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _C.primary.withValues(alpha: 0.08),
                  blurRadius: 40,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Large quote mark
                Positioned(
                  top: -4,
                  right: 0,
                  child: Text(
                    '"',
                    style: _display(
                      120,
                      color: _C.primaryLt,
                      fw: FontWeight.w900,
                    ),
                  ),
                ),

                Column(
                  children: [
                    Text(
                      '"Vonjiaina a radicalement changé ma façon de gérer mon officine. Non seulement j\'ai réduit mes pertes de stock, mais j\'ai également vu ma clientèle s\'élargir grâce à leur plateforme de recherche."',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.sora(
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                        color: _C.ink,
                        height: 1.6,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Avatar + name
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [_C.primary, _C.accent],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dr. Rakoto',
                              style: _display(
                                16,
                                color: _C.ink,
                                fw: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'TITULAIRE D\'OFFICINE',
                              style: _body(
                                12,
                                color: _C.primary,
                                fw: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  CTA SECTION
// ─────────────────────────────────────────────
class _CtaSection extends StatelessWidget {
  const _CtaSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B0E8C), _C.primary, Color(0xFF7C3AED)],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 80),
      child: Column(
        children: [
          // Decorative dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  width: i == 1 ? 10 : 6,
                  height: i == 1 ? 10 : 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: i == 1 ? 0.9 : 0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Prêt à rejoindre\nle réseau ?',
            textAlign: TextAlign.center,
            style: _display(44, color: _C.white),
          ),
          const SizedBox(height: 18),
          Text(
            'Rejoignez des centaines de pharmacies qui font déjà\nconfiance à Vonjiaina.',
            textAlign: TextAlign.center,
            style: _body(17, color: Colors.white.withValues(alpha: 0.75)),
          ),
          const SizedBox(height: 36),

          // White outlined button
          _CtaOutlineButton(
            label: 'CRÉER UN COMPTE',
            onTap: () => context.go(AppRoutes.registerStep1),
          ),
        ],
      ),
    );
  }
}

class _CtaOutlineButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _CtaOutlineButton({required this.label, required this.onTap});
  @override
  State<_CtaOutlineButton> createState() => _CtaOutlineButtonState();
}

class _CtaOutlineButtonState extends State<_CtaOutlineButton> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 17),
          decoration: BoxDecoration(
            color: _hovered ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _hovered ? _C.primary : _C.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  FOOTER
// ─────────────────────────────────────────────
class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _C.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 56),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand column
                Expanded(
                  flex: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _C.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.local_pharmacy_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text('Vonjiaina', style: _display(18, color: _C.ink)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: 200,
                        child: Text(
                          'La solution digitale pour les pharmacies modernes à Madagascar.',
                          style: _body(14),
                        ),
                      ),
                    ],
                  ),
                ),

                // Support
                Expanded(
                  flex: 20,
                  child: _FooterColumn(
                    title: 'Support',
                    links: ['Aide en ligne', 'Contact', 'Confidentialité'],
                  ),
                ),

                // Social
                Expanded(
                  flex: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Réseaux Sociaux',
                        style: _body(15, color: _C.ink, fw: FontWeight.w700),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          _SocialIcon(Icons.share_rounded),
                          const SizedBox(width: 10),
                          _SocialIcon(Icons.language_rounded),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom bar
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: _C.border)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '© 2026 Vonjiaina. Tous droits réservés.',
                  style: _body(13),
                ),
                Row(
                  children: [
                    Text("Conditions d'utilisation", style: _body(13)),
                    const SizedBox(width: 28),
                    Text('Mentions légales', style: _body(13)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<String> links;
  const _FooterColumn({required this.title, required this.links});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: _body(15, color: _C.ink, fw: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        ...links.map(
          (l) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _FooterLink(label: l),
          ),
        ),
      ],
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String label;
  const _FooterLink({required this.label});
  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 150),
        style: _body(14, color: _hovered ? _C.primary : _C.muted),
        child: Text(widget.label),
      ),
    );
  }
}

class _SocialIcon extends StatefulWidget {
  final IconData icon;
  const _SocialIcon(this.icon);
  @override
  State<_SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<_SocialIcon> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _hovered ? _C.primaryLt : const Color(0xFFF3F4F6),
          shape: BoxShape.circle,
          border: Border.all(
            color: _hovered
                ? _C.primary.withValues(alpha: 0.4)
                : Colors.transparent,
          ),
        ),
        child: Icon(
          widget.icon,
          size: 18,
          color: _hovered ? _C.primary : _C.muted,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED BUTTON WIDGETS
// ─────────────────────────────────────────────
class _PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final EdgeInsets padding;
  final double fontSize;
  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.fontSize = 13,
  });
  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: _hovered ? _C.primaryDk : _C.primary,
            borderRadius: BorderRadius.circular(10),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: _C.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: widget.fontSize,
              fontWeight: FontWeight.w700,
              color: _C.white,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final EdgeInsets padding;
  const _OutlineButton({
    required this.label,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  });
  @override
  State<_OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<_OutlineButton> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: _hovered ? _C.primaryLt : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _C.primary, width: 1.5),
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _C.primary,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}
