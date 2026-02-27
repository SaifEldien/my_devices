import '../core.dart';

class AnalyticsBar extends StatelessWidget {
  final List<int> analytics;
  const AnalyticsBar({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    final int total = analytics[0];
    final int available = analytics[2];
    final int rented = analytics[1];
    final int overdue = analytics[3];
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Pie Chart with labels
             SizedBox(
              width: 120,
              height: 120,
              child:total==0 ?  Icon(Icons.hourglass_empty,color: Colors.grey,size: 120,) : CustomPaint(
                painter: PieChartWithLabelsPainter(
                  available: available,
                  rented: rented,
                  overdue: overdue,
                  total: total,
                ),
              ),
            ) ,
            const SizedBox(width: 8),

            // Stats on the right
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildStatButton("total".tr() ,0 ,total, context.watch<ThemeProvider>().isDark? Colors.white : Colors.black, () {
                        Provider.of<DeviceProvider>(context, listen: false).setFilter(filter: 0);
                      }, context),
                      buildStatButton("available".tr(),2 , available, Colors.lightBlue, () {
                        Provider.of<DeviceProvider>(context, listen: false).setFilter(filter: 2);
                      }, context),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildStatButton("rented".tr(),1 ,rented, Colors.orange, () {
                        Provider.of<DeviceProvider>(context, listen: false).setFilter(filter: 1);
                      }, context),
                      buildStatButton("overdue".tr(),3 ,overdue, Colors.red, () {
                        Provider.of<DeviceProvider>(context, listen: false).setFilter(filter: 3);
                      }, context),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStatButton(String title, int filter ,int count, Color color, VoidCallback onTap, BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 90,
        margin: EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.4),
            width: filter == context.watch<DeviceProvider>().currentFilter && title != 'total'.tr() ? 7 : 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              count.toString(),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class PieChartWithLabelsPainter extends CustomPainter {
  final int total;
  final int available;
  final int rented;
  final int overdue;

  PieChartWithLabelsPainter({
    required this.total,
    required this.available,
    required this.rented,
    required this.overdue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = min(size.width, size.height) / 2;

    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    double startAngle = -pi / 2;

    void drawSlice(int value, Color color, String label) {
      if (value == 0) return;

      double sweepAngle = 2 * pi * (value / total);
      paint.color = color;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, true, paint);

      // Draw label
      final double labelAngle = startAngle + sweepAngle / 2;
      final double labelRadius = radius * 0.65;
      final Offset labelPos = Offset(
        center.dx + labelRadius * cos(labelAngle),
        center.dy + labelRadius * sin(labelAngle),
      );

      TextSpan span = TextSpan(
        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
        text: "\n$label",
      );

      TextPainter tp = TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);

      tp.layout();
      tp.paint(canvas, labelPos - Offset(tp.width / 2, tp.height / 2));

      startAngle += sweepAngle;
    }

    drawSlice(available, Colors.blue, "available".tr());
    drawSlice(rented, Colors.orange, "rented".tr());
    drawSlice(overdue, Colors.red, "overdue".tr());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
