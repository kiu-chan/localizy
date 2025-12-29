import 'package:flutter/material.dart';
import 'package:localizy/services/directions_service.dart';
import 'package:localizy/l10n/app_localizations.dart';

class DirectionsPanel extends StatefulWidget {
  final DirectionsResult? directionsResult;
  final VoidCallback onClose;
  final int currentStepIndex;
  final double? distanceToNextStep;
  final bool isNavigating;
  final VoidCallback? onStartNavigation;
  final VoidCallback? onStopNavigation;

  const DirectionsPanel({
    super.key,
    required this.directionsResult,
    required this.onClose,
    this.currentStepIndex = 0,
    this.distanceToNextStep,
    this.isNavigating = false,
    this.onStartNavigation,
    this.onStopNavigation,
  });

  @override
  State<DirectionsPanel> createState() => _DirectionsPanelState();
}

class _DirectionsPanelState extends State<DirectionsPanel> {
  bool _isExpanded = false;

  String _formatDistance(double?  meters) {
    if (meters == null) return '';
    if (meters < 1000) {
      return '${meters.toInt()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.directionsResult == null) return const SizedBox. shrink();

    final l10n = AppLocalizations.of(context);
    final currentStep = widget.currentStepIndex < widget.directionsResult!.steps.length
        ? widget.directionsResult!.steps[widget. currentStepIndex]
        :  null;

    return Positioned(
      left: 0,
      right:  0,
      bottom: 0,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Navigation card - hiển thị khi đang điều hướng
            if (widget.isNavigating && currentStep != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius:  10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.distanceToNextStep != null)
                      Text(
                        _formatDistance(widget.distanceToNextStep),
                        style:  const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      currentStep. instructions,
                      style: const TextStyle(
                        color: Colors. white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color:  Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          currentStep.duration,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.straighten,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width:  4),
                        Text(
                          currentStep.distance,
                          style: const TextStyle(
                            color: Colors. white70,
                            fontSize:  14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            // Main panel
            GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta! < -10) {
                  if (! _isExpanded) {
                    setState(() {
                      _isExpanded = true;
                    });
                  }
                } else if (details.primaryDelta! > 10) {
                  if (_isExpanded) {
                    setState(() {
                      _isExpanded = false;
                    });
                  }
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: _isExpanded 
                    ? MediaQuery.of(context).size.height * 0.6 
                    : (widget.isNavigating ? 140 : 180),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius:  10,
                      offset:  const Offset(0, -2),
                    ),
                  ],
                ),
                child:  Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius:  BorderRadius.circular(2),
                      ),
                    ),
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.directions_car,
                            color: Colors. green.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      widget.directionsResult!.duration,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight:  FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '(${widget.directionsResult!. distance})',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                if (widget.isNavigating)
                                  Text(
                                    '${l10n?.step ??  'Step'} ${widget.currentStepIndex + 1}/${widget.directionsResult!.steps.length}',
                                    style: TextStyle(
                                      fontSize:  12,
                                      color: Colors.grey[600],
                                    ),
                                  )
                                else
                                  Text(
                                    l10n?.fastestRoute ?? 'Fastest route',
                                    style: TextStyle(
                                      fontSize:  12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Start/Stop navigation button
                          if (! widget.isNavigating && widget.onStartNavigation != null)
                            ElevatedButton.icon(
                              onPressed: widget.onStartNavigation,
                              icon: const Icon(Icons.navigation, size: 18),
                              label: Text(l10n?.start ?? 'Start'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor:  Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            )
                          else if (widget.isNavigating && widget. onStopNavigation != null)
                            ElevatedButton. icon(
                              onPressed:  widget.onStopNavigation,
                              icon: const Icon(Icons.stop, size: 18),
                              label: Text(l10n?.stop ?? 'Stop'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: widget.onClose,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // Steps list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: widget.directionsResult!. steps.length,
                        itemBuilder: (context, index) {
                          final step = widget. directionsResult!.steps[index];
                          final isLast = index == widget.directionsResult!.steps.length - 1;
                          final isCurrent = index == widget.currentStepIndex;
                          
                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Step indicator
                                Column(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: isCurrent
                                            ? Colors.blue
                                            : (isLast 
                                                ? Colors.red 
                                                : Colors. green. shade700),
                                        shape: BoxShape.circle,
                                        border: isCurrent
                                            ? Border.all(color: Colors.blue. shade900, width: 2)
                                            : null,
                                      ),
                                      child: Center(
                                        child: isLast
                                            ? const Icon(
                                                Icons.location_on,
                                                color: Colors.white,
                                                size: 14,
                                              )
                                            : Text(
                                                '${index + 1}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                    ),
                                    if (! isLast)
                                      Expanded(
                                        child:  Container(
                                          width: 2,
                                          color: isCurrent 
                                              ? Colors.blue. shade300
                                              : Colors.grey[300],
                                          margin: const EdgeInsets.symmetric(vertical: 4),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                // Step details
                                Expanded(
                                  child:  Padding(
                                    padding:  const EdgeInsets.only(bottom: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          step.instructions,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: isCurrent 
                                                ? FontWeight. bold 
                                                : FontWeight. w500,
                                            color: isCurrent 
                                                ? Colors.blue.shade900
                                                :  Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${step.distance} • ${step.duration}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}