import 'package:flutter/material.dart';
import '../services/emotional_feedback_service.dart';
import '../services/tts_service.dart';
import 'dart:math';

/// 📚 Document & Concept Selector Widget
/// 
/// This widget appears at the top of game screens to allow users to select
/// study documents or concepts to focus their learning on specific topics.
class DocumentConceptSelector extends StatefulWidget {
  final Function(StudyDocument?)? onDocumentSelected;
  final Function(String?)? onConceptSelected;
  final List<StudyDocument> availableDocuments;
  final List<String> availableConcepts;
  final StudyDocument? selectedDocument;
  final String? selectedConcept;
  final bool showDocuments;
  final bool showConcepts;

  const DocumentConceptSelector({
    super.key,
    this.onDocumentSelected,
    this.onConceptSelected,
    this.availableDocuments = const [],
    this.availableConcepts = const [],
    this.selectedDocument,
    this.selectedConcept,
    this.showDocuments = true,
    this.showConcepts = true,
  });

  @override
  State<DocumentConceptSelector> createState() => _DocumentConceptSelectorState();
}

class _DocumentConceptSelectorState extends State<DocumentConceptSelector>
    with TickerProviderStateMixin {
  final TTSService _ttsService = TTSService();
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Start subtle pulse animation
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _slideController.forward();
      _ttsService.speak('Study materials selector opened');
    } else {
      _slideController.reverse();
      _ttsService.speak('Study materials selector closed');
    }
    
    EmotionalFeedbackService.provideMicroFeedback(context, 'button_press');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.purple.shade50],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                // Header - Always visible
                _buildHeader(),
                
                // Expandable content
                if (_isExpanded)
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildExpandedContent(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final hasSelection = widget.selectedDocument != null || widget.selectedConcept != null;
    
    return GestureDetector(
      onTap: _toggleExpanded,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: hasSelection ? Colors.green.shade100 : Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                hasSelection ? Icons.check_circle : Icons.library_books,
                color: hasSelection ? Colors.green : Colors.blue,
                size: 20,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasSelection ? 'Study Focus Selected' : 'Choose Study Focus',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: hasSelection ? Colors.green.shade700 : Colors.blue.shade700,
                    ),
                  ),
                  
                  const SizedBox(height: 2),
                  
                  Text(
                    _getSelectionDescription(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Expand/Collapse icon
            Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.blue.shade600,
            ),
          ],
        ),
      ),
    );
  }

  String _getSelectionDescription() {
    if (widget.selectedDocument != null) {
      return 'Document: ${widget.selectedDocument!.title}';
    } else if (widget.selectedConcept != null) {
      return 'Concept: ${widget.selectedConcept}';
    } else {
      return 'Tap to select study materials or concepts';
    }
  }

  Widget _buildExpandedContent() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Documents section
          if (widget.showDocuments) ...[
            _buildSectionHeader('Study Documents', Icons.description),
            const SizedBox(height: 8),
            _buildDocumentsList(),
            const SizedBox(height: 16),
          ],
          
          // Concepts section
          if (widget.showConcepts) ...[
            _buildSectionHeader('Key Concepts', Icons.lightbulb),
            const SizedBox(height: 8),
            _buildConceptsList(),
            const SizedBox(height: 8),
          ],
          
          // Clear selection button
          if (widget.selectedDocument != null || widget.selectedConcept != null)
            _buildClearButton(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsList() {
    if (widget.availableDocuments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: Colors.grey.shade500),
            const SizedBox(width: 8),
            Text(
              'No documents uploaded yet',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: widget.availableDocuments.map((document) {
        final isSelected = widget.selectedDocument?.id == document.id;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                widget.onDocumentSelected?.call(isSelected ? null : document);
                EmotionalFeedbackService.provideMicroFeedback(context, 'button_press');
                _ttsService.speak(isSelected 
                    ? 'Document deselected' 
                    : 'Selected document: ${document.title}');
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.shade100 : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getDocumentIcon(document.type),
                      size: 20,
                      color: isSelected ? Colors.blue : Colors.grey.shade600,
                    ),
                    
                    const SizedBox(width: 12),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            document.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.blue.shade700 : Colors.black87,
                            ),
                          ),
                          
                          if (document.description.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              document.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: Colors.blue,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConceptsList() {
    if (widget.availableConcepts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: Colors.grey.shade500),
            const SizedBox(width: 8),
            Text(
              'No concepts available',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.availableConcepts.map((concept) {
        final isSelected = widget.selectedConcept == concept;
        
        return GestureDetector(
          onTap: () {
            widget.onConceptSelected?.call(isSelected ? null : concept);
            EmotionalFeedbackService.provideMicroFeedback(context, 'button_press');
            _ttsService.speak(isSelected 
                ? 'Concept deselected' 
                : 'Selected concept: $concept');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.purple.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.purple : Colors.grey.shade300,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.purple,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  concept,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.purple.shade700 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildClearButton() {
    return Container(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () {
          widget.onDocumentSelected?.call(null);
          widget.onConceptSelected?.call(null);
          EmotionalFeedbackService.provideMicroFeedback(context, 'button_press');
          _ttsService.speak('Selection cleared');
        },
        icon: const Icon(Icons.clear, size: 16),
        label: const Text('Clear Selection'),
        style: TextButton.styleFrom(
          foregroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return Icons.picture_as_pdf;
      case DocumentType.word:
        return Icons.description;
      case DocumentType.powerpoint:
        return Icons.slideshow;
      case DocumentType.text:
        return Icons.text_snippet;
      case DocumentType.image:
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
}

/// 📄 Study Document Model
class StudyDocument {
  final String id;
  final String title;
  final String description;
  final DocumentType type;
  final String filePath;
  final DateTime uploadDate;
  final List<String> keyTerms;
  final String subject;

  const StudyDocument({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.filePath,
    required this.uploadDate,
    this.keyTerms = const [],
    this.subject = '',
  });

  factory StudyDocument.fromFile(String filePath, String title) {
    final extension = filePath.split('.').last.toLowerCase();
    DocumentType type;
    
    switch (extension) {
      case 'pdf':
        type = DocumentType.pdf;
        break;
      case 'doc':
      case 'docx':
        type = DocumentType.word;
        break;
      case 'ppt':
      case 'pptx':
        type = DocumentType.powerpoint;
        break;
      case 'txt':
        type = DocumentType.text;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
        type = DocumentType.image;
        break;
      default:
        type = DocumentType.other;
    }

    return StudyDocument(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: 'Uploaded ${extension.toUpperCase()} document',
      type: type,
      filePath: filePath,
      uploadDate: DateTime.now(),
    );
  }
}

/// 📁 Document Types
enum DocumentType {
  pdf,
  word,
  powerpoint,
  text,
  image,
  other,
}

/// 🎯 Sample Documents Factory
class SampleDocuments {
  static List<StudyDocument> getNepalSamples() {
    return [
      StudyDocument(
        id: 'nepal_history',
        title: 'History of Nepal',
        description: 'Ancient kingdoms to modern republic',
        type: DocumentType.pdf,
        filePath: 'assets/docs/nepal_history.pdf',
        uploadDate: DateTime.now().subtract(const Duration(days: 2)),
        keyTerms: ['Prithvi Narayan Shah', 'Unification', 'Gorkha Kingdom', 'Democracy'],
        subject: 'History',
      ),
      
      StudyDocument(
        id: 'nepal_geography',
        title: 'Geography of Nepal',
        description: 'Mountains, hills, and Terai plains',
        type: DocumentType.word,
        filePath: 'assets/docs/nepal_geography.docx',
        uploadDate: DateTime.now().subtract(const Duration(days: 1)),
        keyTerms: ['Himalayas', 'Mount Everest', 'Terai', 'Rivers'],
        subject: 'Geography',
      ),
      
      StudyDocument(
        id: 'nepali_culture',
        title: 'Nepali Culture & Festivals',
        description: 'Rich traditions and celebrations',
        type: DocumentType.powerpoint,
        filePath: 'assets/docs/nepali_culture.pptx',
        uploadDate: DateTime.now(),
        keyTerms: ['Dashain', 'Tihar', 'Holi', 'Buddha Jayanti'],
        subject: 'Culture',
      ),
      
      StudyDocument(
        id: 'math_basics',
        title: 'Basic Mathematics',
        description: 'Fundamental math concepts',
        type: DocumentType.pdf,
        filePath: 'assets/docs/math_basics.pdf',
        uploadDate: DateTime.now().subtract(const Duration(hours: 6)),
        keyTerms: ['Addition', 'Subtraction', 'Multiplication', 'Division'],
        subject: 'Mathematics',
      ),
      
      StudyDocument(
        id: 'science_intro',
        title: 'Introduction to Science',
        description: 'Basic scientific principles',
        type: DocumentType.text,
        filePath: 'assets/docs/science_intro.txt',
        uploadDate: DateTime.now().subtract(const Duration(hours: 3)),
        keyTerms: ['Physics', 'Chemistry', 'Biology', 'Scientific Method'],
        subject: 'Science',
      ),
    ];
  }

  static List<String> getNepalConcepts() {
    return [
      // History Concepts
      'Ancient Nepal',
      'Licchavi Dynasty',
      'Malla Period',
      'Unification of Nepal',
      'Rana Regime',
      'Democracy Movement',
      
      // Geography Concepts
      'Himalayan Region',
      'Hill Region',
      'Terai Region',
      'Major Rivers',
      'Climate Zones',
      'Natural Resources',
      
      // Culture Concepts
      'Hindu Festivals',
      'Buddhist Traditions',
      'Ethnic Diversity',
      'Traditional Arts',
      'Folk Music',
      'Traditional Dress',
      
      // Language Concepts
      'Nepali Language',
      'Devanagari Script',
      'Regional Languages',
      'Literature',
      
      // Mathematics Concepts
      'Basic Operations',
      'Fractions',
      'Geometry',
      'Algebra',
      'Statistics',
      
      // Science Concepts
      'Human Body',
      'Plant Life',
      'Solar System',
      'Matter and Energy',
      'Environment',
    ];
  }
}