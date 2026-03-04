import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mindcare/features/psychiatrist/psychiatrist_self_assessment _result.dart';

class PsychiatristSelfAssessmentPage extends StatefulWidget {
  final bool isViewOnly;

  const PsychiatristSelfAssessmentPage({super.key, this.isViewOnly = false});

  @override
  State<PsychiatristSelfAssessmentPage> createState() => _PsychiatristSelfAssessmentPageState();
}

class _PsychiatristSelfAssessmentPageState extends State<PsychiatristSelfAssessmentPage> {
  final List<String> questions = [
    "ท่านรู้สึกพึงพอใจในชีวิต",
    "ท่านรู้สึกสบายใจ",
    "ท่านรู้สึกสดชื่นเบิกบานใจ",
    "ท่านรู้สึกชีวิตของท่านมีความสุขสงบ",
    "ท่านรู้สึกเบื่อหน่ายท้อแท้กับการดำเนินชีวิตประจำวัน",
    "ท่านรู้สึกผิดหวังในตัวเอง",
    "ท่านรู้สึกว่าชีวิตของท่านมีแต่ความทุกข์",
    "ท่านรู้สึกกังวลใจ",
    "ท่านรู้สึกเศร้าโดยไม่ทราบสาเหตุ",
    "ท่านรู้สึกโกรธหงุดหงิดง่ายโดยไม่ทราบสาเหตุ",
    // "ท่านต้องไปรับการรักษาพยาบาลเสมอๆ เพื่อให้สามารถดำเนินชีวิตและทำงานได้",
    // "ท่านเป็นโรคเรื้อรัง (เบาหวาน ความดันโลหิตสูง อัมพาต ลมชัก ฯลฯ ในกรณีถ้ามีให้ระบุว่ามีความรุนแรงของโรคเล็กน้อยหรือมากตามอาการที่มี",
    // "ท่านรู้สึกกังวลหรือทุกข์ทรมานใจเกี่ยวกับการเจ็บป่วยของท่าน",
    // "ท่านพอใจต่อการผูกมิตรหรือเข้ากับบุคคลอื่น",
    // "ท่านมีสัมพันธภาพที่ดีกับเพื่อนบ้าน",
    // "ท่านมีสัมพันธภาพที่ดีกับเพื่อนร่วมงาน (ทำงานร่วมกับคนอื่น)",
    // "ท่านคิดว่าท่านมีความเป็นอยู่และฐานะทางสังคม ตามที่ท่านได้คาดหวังไว้",
    // "ท่านรู้สึกประสบความสำเร็จและความก้าวหน้าในชีวิต",
    // "ท่านรู้สึกพึงพอใจกับฐานะความเป็นอยู่ของท่าน",
    // "ท่านเห็นว่าปัญหาส่วนใหญ่เป็นสิ่งที่แก้ไขได้",
    // "ท่านสามารถทำใจยอมรับได้สำหรับปัญหาที่ยากจะแก้ไข (เมื่อมีปัญหา)",
    // "ท่านมั่นใจว่าจะสามารถควบคุมอารมณ์ได้ เมื่อมีเหตุการณ์คับขันหรือร้ายแรงเกิดขึ้น",
    // "ท่านมั่นใจที่จะเผชิญกับเหตุการณ์ร้ายแรงที่เกิดขึ้นในชีวิต",
    // "ท่านแก้ปัญหาที่ขัดแย้งได้",
    // "ท่านจะรู้สึกหงุดหงิด ถ้าสิ่งต่างๆ ไม่เป็นไปตามที่คาดหวัง",
    // "ท่านหงุดหงิดโมโหง่ายถ้าท่านถูกวิพากษ์วิจารณ์",
    // "ท่านรู้สึกหงุดหงิด กังวลใจกับเรื่องเล็กๆน้อยๆ ที่เกิดขึ้นเสมอ",
    // "ท่านรู้สึกกังวลใจกับเรื่องทุกเรื่องที่มากระทบตัวท่าน",
    // "ท่านรู้สึกยินดีกับความสำเร็จของคนอื่น",
    // "ท่านรู้สึกเห็นใจเมื่อผู้อื่นมีทุกข์",
    // "ท่านรู้สึกเป็นสุขในการช่วยเหลือผู้อื่นเมื่อมีโอกาส",
    // "ท่านให้ความช่วยเหลือแก่ผู้อื่นเมื่อมีโอกาส",
    // "ท่านเสียสละแรงกายหรือทรัพย์สินเพื่อประโยชน์ส่วนรวมโดยไม่หวังผลตอบแทน",
    // "หากมีสถานการณ์ที่คับขันเสี่ยงภัย ท่านพร้อมที่จะให้ความช่วยเหลือร่วมกับผู้อื่น",
    // "ท่านพึงพอใจกับความสามารถของตนเอง",
    // "ท่านรู้สึกภูมิใจในตนเอง",
    // "ท่านรู้สึกว่าท่านมีคุณค่าต่อครอบครัว",
    // "ท่านมีสิ่งยึดเหนี่ยวสูงสุดในจิตใจที่ทำให้จิตใจมั่นคงในการดำเนินชีวิต",
    // "ท่านมีความเชื่อมั่นว่าเมื่อเผชิญกับความยุ่งยากท่านมีสิ่งยึดเหนี่ยวสูงสุดในจิตใจ",
    // "ท่านเคยประสบกับความยุ่งยากและสิ่งยึดเหนี่ยวสูงสุดในจิตใจช่วยให้ท่านผ่านพ้นไปได้",
    // "ท่านต้องการทำบางสิ่งที่ใหม่ในทางที่ดีขึ้นกว่าที่เป็นอยู่เดิม",
    // "ท่านมีความสุขกับการริเริ่มงานใหม่ๆ และมุ่งมั่นที่จะทำให้สำเร็จ",
    // "ท่านมีความกระตือรือร้นที่จะเรียนรู้สิ่งใหม่ๆ ในทางที่ดี",
    // "ท่านมีเพื่อนหรือคนอื่นๆ ในสังคมคอยช่วยเหลือท่านในยามที่ต้องการ",
    // "ท่านได้รับความช่วยเหลือตามที่ท่านต้องการจากเพื่อนหรือคนอื่นๆในสังคม",
    // "ท่านรู้สึกมั่นคง ปลอดภัยเมื่ออยู่ในครอบครัว",
    // "หากท่านป่วยหนัก ท่านเชื่อว่าครอบครัวจะดูแลท่านเป็นอย่างดี",
    // "ท่านปรึกษาหรือขอความช่วยเหลือจากครอบครัวเสมอเมื่อท่านมีปัญหา",
    // "สมาชิกในครอบครัวมีความรักและผูกพันต่อกัน",
    // "ท่านมั่นใจว่าชุมชนที่ท่านอาศัยอยู่มีความปลอดภัยต่อท่าน",
    // "ท่านรู้สึกมั่นคงปลอดภัยในทรัพย์สินเมื่ออาศัยอยู่ในชุมชนนี้",
    // "มีหน่วยงานสาธารณสุขใกล้บ้านที่ท่านสามารถไปใช้บริการได้",
    // "หน่วยงานสาธารณสุขใกล้บ้านสามารถไปให้บริการได้เมื่อท่านต้องการ",
    // "เมื่อท่านหรือญาติเจ็บป่วยจะไช้บริการจากหน่วยงานสาธารณสุขใกล้บ้าน",
    // "เมื่อท่านเดือดร้อนจะมีหน่วยงานในชุมชน(เช่น มูลนิธิ ชมรม สมาคม วัด สุเหร่า ฯลฯ) มาช่วยเหลือดูแลท่าน"
  ];
  final Set<int> reverseScoreQuestions = {
    5,6,7,8,9,10,11,12,13,25,26,27,28
  };
  final int questionsPerPage = 5;
  bool isUnanswer = false;
  int currentStep = 0;
  int get stepsQuestion => (questions.length / questionsPerPage).ceil();
  int calculateTotalScore() {
    int total = 0;
    for (int i = 0; i < answers.length; i++) {
      int answer = answers[i]; // 1-4
      int questionNumber = i + 1;
      if (reverseScoreQuestions.contains(questionNumber)) {
        // กลุ่มที่ 2 (กลับคะแนน)
        total += (5 - answer);
      } else {
        // กลุ่มที่ 1
        total += answer;
      }
    }
    return total;
  }
  String interpretResult(int score) {
    if (score >= 179) {
      return "Good";
    } else if (score >= 158) {
      return "Fair";
    } else {
      return "Poor";
    }
  }
  bool get isCurrentPageValid {
    final start = currentStep * questionsPerPage;
    final end = (start + questionsPerPage).clamp(0, questions.length);

    return !answers.sublist(start, end).contains(0);
  }

  Set<int> invalidQuestions = {};
  List<int> answers = [];

  List<String> get currentQuestions {
    final start = currentStep * questionsPerPage;
    final end = (start + questionsPerPage).clamp(0, questions.length);
    return questions.sublist(start, end);
  }

  @override
  void initState() {
    super.initState();
    answers = List.filled(questions.length, 0);

    if (widget.isViewOnly) {
      loadLatestAssessment();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Self Assessment',
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Choose how accurately each statement reflects you.",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),
            
            _progressHeader(),

            const SizedBox(height: 12),

            _scaleLegend(),

            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                itemCount: currentQuestions.length,
                itemBuilder: (context, i) {
                  final globalIndex = currentStep * questionsPerPage + i;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _questionCard(globalIndex),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "All questions must be answered before you continue.",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: isUnanswer ? Colors.red : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 5),

            _nextButton(),

            const SizedBox(height: 12),

            _backButton(),
          ],
        ),
      ),
    );
  }

  Future<void> loadLatestAssessment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('self_assessment_results')
        .doc(user.uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;
    final List<dynamic> savedAnswers = data["answers"];

    setState(() {
      answers = savedAnswers.map((e) => e as int).toList();
      currentStep = (questions.length / questionsPerPage).ceil() - 1;
    });
  }

  Widget _progressHeader() {
    final percent = widget.isViewOnly
      ? 1.0
      : currentStep * questionsPerPage / questions.length;
    Color barColor = Colors.teal;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // ซ้าย: เปอร์เซ็นต์
              Text(
                "${(percent * 100).toInt()}%",
                style: TextStyle(
                  color: barColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(), // ดันข้อความไปขวาสุด
              // ขวา: Step x of y
              Text(
                "Step ${currentStep + 1} of $stepsQuestion",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 10,
            child: LinearProgressIndicator(
              value: percent,
              color: barColor,
              backgroundColor: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),      
        ],
      )
    );
  }

  Widget _scaleLegend() {
    final labels = ["ไม่เลย", "เล็กน้อย", "มาก", "มากที่สุด"];
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.green,
      Colors.green.shade800,
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(4, (i) {
        return Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors[i], // สีขอบ
                  width: 1,
                ),
                color: colors[i].withOpacity(0.2), // สีด้านในอ่อนกว่า
              ),
            ),
            const SizedBox(height: 8),
            Text(
              labels[i],
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _questionCard(int globalIndex) {
    final question = questions[globalIndex];
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.green,
      Colors.green.shade800,
    ];

    final isInvalid = invalidQuestions.contains(globalIndex);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isInvalid ? Colors.red : Colors.transparent,
          width: 1,
        ),
      ),
      // color: const Color(0xFFF3F9FF),
      color: const Color.fromARGB(255, 255, 255, 255),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              question,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (i) {
                final isSelected = answers[globalIndex] == i + 1;
                return GestureDetector(
                  onTap: widget.isViewOnly ? null : () {
                    setState(() {
                      if (answers[globalIndex] == i + 1) {
                        answers[globalIndex] = 0; // ยกเลิก
                      } else {
                        answers[globalIndex] = i + 1;
                      }
                    });
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor:
                      isSelected ? colors[i] : Colors.white,
                    child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 18,
                        )
                      : Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors[i], // สีขอบ
                            width: 1,
                          ),
                          color: colors[i].withOpacity(0.2), // สีด้านในอ่อนกว่า
                        ),
                      ),
                  ),
                );
              }),
            )
          ],
        ),
      ),
    );
  }

  Widget _nextButton() {
    final isLastStep = currentStep == stepsQuestion - 1;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
        ),
        onPressed: () {
          final start = currentStep * questionsPerPage;
          final end = (start + questionsPerPage).clamp(0, questions.length);

          invalidQuestions.clear();

          for (int i = start; i < end; i++) {
            if (answers[i] == 0) {
              invalidQuestions.add(i);
            }
          }

          if (invalidQuestions.isNotEmpty) {
            setState(() {
              isUnanswer = true;
            });
            return;
          }

          setState(() {
            isUnanswer = false;
          });

          if (isLastStep) {
            submitAssessment();
          } else {
            setState(() {
              currentStep++;
            });
          }
        },
        child: Text(
          isLastStep ? "ส่งแบบประเมิน" : "ถัดไป",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            ),
        ),
      ),
    );
  }

  Widget _backButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 0,
          side: const BorderSide(
            color: Colors.teal
          ),
        ),
        onPressed: () {
          if (currentStep == 0) {
            return;
          }
          setState(() {
            currentStep--;
          });
        },
        child: const Text(
          "ย้อนกลับ",
          style: TextStyle(
            color: Colors.teal,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> submitAssessment() async {
    final totalScore = calculateTotalScore();
    final result = interpretResult(totalScore);

    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection("self_assessment_results")
        .doc(user!.uid)
        .set({
      "score": totalScore,
      "result": result,
      "answers": answers,
      "createdAt": Timestamp.now(),
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PsychiatristSelfAssessmentResultPage(
          // score: totalScore,
          // result: result,
        ),
      ),
    );
  }
}