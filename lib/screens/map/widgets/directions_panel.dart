import 'package:flutter/material.dart';
import 'package:localizy/services/directions_service.dart';

class DirectionsPanel extends StatelessWidget {
  final DirectionsResult? directionsResult;
  final VoidCallback onClose;

  const DirectionsPanel({
    super.key,
    required this. directionsResult,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (directionsResult == null) return const SizedBox. shrink();

    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.1,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:  CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.directions_car,
                                color: Colors.green.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                directionsResult!.duration,
                                style: const TextStyle(
                                  fontSize:  20,
                                  fontWeight:  FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${directionsResult!.distance})',
                                style: TextStyle(
                                  fontSize:  14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tuyến đường nhanh nhất',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors. grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons. close),
                      onPressed:  onClose,
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Steps list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: directionsResult! .steps.length,
                  itemBuilder: (context, index) {
                    final step = directionsResult!.steps[index];
                    final isLast = index == directionsResult!.steps.length - 1;
                    
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Step indicator
                            Column(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isLast 
                                        ? Colors.red 
                                        : Colors.green.shade700,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: isLast
                                        ? const Icon(
                                            Icons. location_on,
                                            color: Colors.white,
                                            size: 16,
                                          )
                                        : Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                                if (! isLast)
                                  Container(
                                    width: 2,
                                    height: 40,
                                    color: Colors.grey[300],
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            // Step details
                            Expanded(
                              child:  Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Column(
                                  crossAxisAlignment:  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      step.instructions,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight:  FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${step.distance} • ${step.duration}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors. grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}