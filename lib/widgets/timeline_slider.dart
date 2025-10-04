import 'package:flutter/material.dart';

class TimelineSlider extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final Function(int, int) onSelectionChanged;

  const TimelineSlider({
    super.key,
    required this.data,
    required this.onSelectionChanged,
  });

  @override
  State<TimelineSlider> createState() => _TimelineSliderState();
}

class _TimelineSliderState extends State<TimelineSlider> {
  int _selectedLeftIndex = 0;
  int _selectedRightIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 80,
          child: Row(
            children: [
              for (int i = 0; i < widget.data.length; i++)
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTimePoint(i),
                    child: _buildTimelinePoint(i),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            _buildSelectionCard('Before', _selectedLeftIndex, (index) {
              setState(() {
                _selectedLeftIndex = index;
                widget.onSelectionChanged(_selectedLeftIndex, _selectedRightIndex);
              });
            }),
            const SizedBox(height: 16),
            _buildSelectionCard('After', _selectedRightIndex, (index) {
              setState(() {
                _selectedRightIndex = index;
                widget.onSelectionChanged(_selectedLeftIndex, _selectedRightIndex);
              });
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelinePoint(int index) {
    final data = widget.data[index];
    final isSelectedLeft = index == _selectedLeftIndex;
    final isSelectedRight = index == _selectedRightIndex;
    final isSelected = isSelectedLeft || isSelectedRight;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        data['label'],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 9,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                if (isSelectedLeft)
                  Positioned(
                    top: 2,
                    left: 2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        'B',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (isSelectedRight)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        'A',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(data['date']),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionCard(String type, int selectedIndex, Function(int) onChanged) {
    final data = widget.data[selectedIndex];
    final color = type == 'Before' ? Colors.green : Colors.orange;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      type == 'Before' ? 'B' : 'A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  type,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: selectedIndex,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: widget.data.asMap().entries.map((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(entry.value['label']),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              data['description'],
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _selectTimePoint(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select as Before or After',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Text(
                  'B',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: const Text('Set as Before'),
              onTap: () {
                setState(() {
                  _selectedLeftIndex = index;
                  widget.onSelectionChanged(_selectedLeftIndex, _selectedRightIndex);
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.orange,
                child: Text(
                  'A',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: const Text('Set as After'),
              onTap: () {
                setState(() {
                  _selectedRightIndex = index;
                  widget.onSelectionChanged(_selectedLeftIndex, _selectedRightIndex);
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}