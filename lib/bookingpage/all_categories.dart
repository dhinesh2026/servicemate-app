import 'package:flutter/material.dart';
import 'package:servicemate_app/bookingpage/book_page.dart';

class CommonProblemsPage extends StatefulWidget {
  final String serviceName;
  final List<Map<String, dynamic>> commonProblems;

  const CommonProblemsPage({
    super.key,
    required this.serviceName,
    required this.commonProblems,
  });

  @override
  State<CommonProblemsPage> createState() => _CommonProblemsPageState();
}

class _CommonProblemsPageState extends State<CommonProblemsPage> {
  final TextEditingController _otherProblemController = TextEditingController();
  int selectedIndex = -1; // Track selected problem

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> problems = List.from(widget.commonProblems);

    // Ensure "Others" is the last option
    if (!problems.any((p) => p['problem'] == 'Others')) {
      problems.add({
        'problem': 'Others',
        'prices': {'fastService': 0, 'scheduledService': 0, 'membership': 0}
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.serviceName),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // Price header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Available service: Fast Service | Scheduled Service | Membership",
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: problems.length,
                    itemBuilder: (context, index) {
                      final problem = problems[index];
                      final bool isOthers = problem['problem'] == 'Others';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        shadowColor: Colors.grey.withOpacity(0.2),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: selectedIndex == index,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedIndex = value! ? index : -1;
                                        });
                                      },
                                      activeColor: Colors.green,
                                    ),
                                    Expanded(
                                      child: Text(
                                        isOthers ? "Other Problems" : problem['problem'],
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blueGrey[900],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (!isOthers) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "Fast: ₹${problem['prices']['fastService']}  |  "
                                      "Scheduled: ₹${problem['prices']['scheduledService']}  |  "
                                      "Membership: ₹${problem['prices']['membership']}",
                                      style: const TextStyle(
                                        color: Colors.blueGrey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                                if (isOthers && selectedIndex == index) ...[
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _otherProblemController,
                                    maxLines: 2,
                                    decoration: InputDecoration(
                                      hintText: "Describe your problem...",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      contentPadding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 16),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 70), // Space for bottom button
              ],
            ),
          ),

          // Bottom Book Service button
          if (selectedIndex != -1)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  onPressed: () {
                    final selectedProblem = problems[selectedIndex]['problem'] == 'Others'
                        ? _otherProblemController.text.trim()
                        : problems[selectedIndex]['problem'];

                    final selectedPrice = problems[selectedIndex]['prices']; // ✅ Always send price

                    if (problems[selectedIndex]['problem'] == 'Others' &&
                        selectedProblem.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter your problem")),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ServiceDetailPage(
                          serviceName: widget.serviceName,
                          selectedProblem: selectedProblem,
                          selectedPrice: selectedPrice, // ✅ "Others" also sends prices (all 0)
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Book Service",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
