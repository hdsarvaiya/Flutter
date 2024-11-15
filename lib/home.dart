import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<File?> _images =
      List.generate(8, (_) => null); // List to hold 8 images
  final List<VideoPlayerController?> _videos =
      List.generate(2, (_) => null); // Video controllers list
  final picker = ImagePicker();
  String? selectedSpecies; // To hold the currently selected species
  String? selectedBreed; // To hold the currently selected breed
  String? selectedBreedType; // To hold the selected breed type

  String? selectedBodyColor; // To hold the selected body color

  String? selectedTailSwitch; // To hold the selected tail switch state

  bool isLeftHornSelected = false; // Selection state for Left Horn
  bool isRightHornSelected = false; // Selection state for Right Horn

  String? selectedLeftHorn; // To hold the selected state for Left Horn
  String? selectedRightHorn; // To hold the selected state for Right Horn

  bool _isTailSwitched = false; // Track state for "Switch of tail"
  int? selectedAge; // To hold the selected approximate age
  int? selectedMilkYield; // To hold the selected approximate age

  int? selectedLactation; // To hold the selected number of lactation (0-9)
  int? selectedCalvingMonth; // To hold the selected calving month (0-10)

  bool isRemarksBoxVisible = false; // Tracks visibility of the remarks box
  TextEditingController remarksController =
      TextEditingController(); // Controller for remarks
  TextEditingController tagController =
      TextEditingController(); // Controller for remarks
  TextEditingController marketValueController=
      TextEditingController(); // Controller for remarks
  TextEditingController vendorRemarkController =
      TextEditingController(); // Controller for remarks
  TextEditingController tagdateController =
      TextEditingController(); // Controller for remarks

  final List<String> cowBreeds = [
    'Holstein Fresian',
    'Jersey',
    'Khillari',
    'Red Kandhari',
    'Gir',
    'Kankarej',
    'Rathi',
    'Other'
  ];

  final List<String> buffaloBreeds = [
    'Murrah',
    'Banni',
    'Surti',
    'Nili-Ravi',
    'Jaffarabadi',
    'Mehsana',
    'Pandharpuri',
    'Kundhi',
    'Kundli',
    'Bengal',
    'Kachi',
    'Tharparkar',
    'Sahiwal',
    'Chhattisgarh'
  ];

  final List<String> otherBreeds = ['Other'];

  final List<String> bodyColors = [
    'Black',
    'Black & White',
    'White & Black',
    'Brown',
    'Brown & Black',
    'Grey',
    'Grey & Black',
  ];

  final List<String> tailSwitchOptions = [
    'Black',
    'Black & White',
    'White & Black',
    'Brown',
    'Brown & Black',
    'Grey',
    'Grey & Black',
  ];

  final List<String> hornOptions = [
    'Downward',
    'Sideward',
    'Forward',
    'Rolled',
    'Short',
    'Curved',
    'Backward',
    'Crescent',
    'Dehorned',
  ];
  Future<void> _pickImage(int index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose an option'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _images[index] = File(pickedFile.path);
                  });
                }
              },
              child: const Text('Pick from Gallery'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final pickedFile =
                    await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() {
                    _images[index] = File(pickedFile.path);
                  });
                }
              },
              child: const Text('Take Photo'),
            ),
          ],
        );
      },
    );
  }

  Future<void> sendDataToBackend(BuildContext context) async {
    // Collect all the form data
    Map<String, dynamic> formData = {
      'selectedSpecies': selectedSpecies,
      'selectedBreed': selectedBreed,
      'selectedBreedType': selectedBreedType,
      'selectedBodyColor': selectedBodyColor,
      'selectedTailSwitch': selectedTailSwitch,
      'selectedAge': selectedAge,
      'selectedLeftHorn': selectedLeftHorn,
      'selectedRightHorn': selectedRightHorn,
      'selectedLactation': selectedLactation,
      'selectedCalvingMonth': selectedCalvingMonth,
      'selectedMilkYield': selectedMilkYield, // Corrected typo here
      'remarks': remarksController.text, // Include the remarks text


      'tagNo': tagController.text, // Add Tag No from the first tab
      'tagDate': tagdateController.text, // Add Tag Date from the first tab
      'marketValue': marketValueController.text, // Add Market Value from the first tab
      'vendorRemark': vendorRemarkController.text, // Add Vendor Remark from the first tab
    };

    const url = 'https://backend-4xmp.onrender.com/api/submit';

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(formData),
      );

      Navigator.pop(context); // Close the loading dialog

      if (response.statusCode == 200) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Data sent successfully")),
        );
      } else {
        // Show failure message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Failed to send data. Status code: ${response.statusCode}")),
        );
      }
    } catch (error) {
      Navigator.pop(context); // Close the loading dialog

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending data: $error")),
      );
    }
  }

  Future<void> _pickVideo(int index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose an option'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final pickedFile =
                    await picker.pickVideo(source: ImageSource.gallery);
                if (pickedFile != null) {
                  final controller =
                      VideoPlayerController.file(File(pickedFile.path));
                  await controller.initialize();
                  setState(() {
                    _videos[index] = controller;
                  });
                }
              },
              child: const Text('Pick from Gallery'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final pickedFile =
                    await picker.pickVideo(source: ImageSource.camera);
                if (pickedFile != null) {
                  final controller =
                      VideoPlayerController.file(File(pickedFile.path));
                  await controller.initialize();
                  setState(() {
                    _videos[index] = controller;
                  });
                }
              },
              child: const Text('Record Video'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadImagesAndVideos() async {
    try {
      List<String> base64Images = [];
      List<String> base64Videos = [];

      // Convert and upload images
      for (var image in _images) {
        if (image != null && await image.exists()) {
          String base64Image = base64Encode(await image.readAsBytes());
          base64Images.add(base64Image);
        }
      }

      // Convert and upload videos
      for (var videoController in _videos) {
        if (videoController != null) {
          final videoFile = File(videoController.dataSource);
          if (await videoFile.exists()) {
            String base64Video = base64Encode(await videoFile.readAsBytes());
            base64Videos.add(base64Video);
          }
        }
      }

      final response = await http.post(
        Uri.parse('https://192.168.29.245:3000/uploadMedia'),
        headers: {"Content-Type": "application/json"},
        body:
            json.encode({'imageData': base64Images, 'videoData': base64Videos}),
      );

      if (response.statusCode == 200) {
        print("Media successfully uploaded and saved in MongoDB.");
      } else {
        print("Failed to upload media to the backend.");
      }
    } catch (e) {
      print("Error uploading media: $e");
    }
  }

// Function to update breed options based on the selected species
  List<String> getBreeds() {
    if (selectedSpecies == 'Cow') {
      return cowBreeds;
    } else if (selectedSpecies == 'Buffalo') {
      return buffaloBreeds;
    } else {
      return []; // Empty list for Other species or if none is selected
    }
  }

  @override
  void dispose() {
    for (var controller in _videos) {
      controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Three tabs: Status, Details, and Image
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Cattle Details"),
          backgroundColor: Colors.brown,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Colors.white, // Set selected tab font color to white
            unselectedLabelColor: Colors
                .white70, // Set unselected tab font color to a lighter white
            tabs: [
              Tab(text: 'Status'),
              Tab(text: 'Details'),
              Tab(text: 'Image'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // First Tab - Status
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Sub Status',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tag No Input
                    const Text(
                      'Tag No',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: tagController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter Tag No',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tag Date Input (Date Picker)
                    const Text(
                      'Tag Date',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: tagdateController, 
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Select Date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          // You can use pickedDate for any other logic if required
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Market Value Input
                    const Text(
                      'Market Value',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: marketValueController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter Market Value',
                        prefixIcon: Icon(Icons.currency_rupee_sharp),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),

                    // Vendor Remark Input
                    const Text(
                      'Vendor Remark',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: vendorRemarkController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter Vendor Remark',
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3, // Allow multiline input for remarks
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            // Second Tab - Details
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Species',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSpeciesOption("Cow", Icons.pets),
                        _buildSpeciesOption("Buffalo", Icons.agriculture),
                        _buildSpeciesOption("Other", Icons.help_outline),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Select Breed',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          hint: const Text("Select Breed"),
                          value: selectedBreed,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          items: getBreeds().map((String breed) {
                            return DropdownMenuItem<String>(
                              value: breed,
                              child: Text(breed),
                            );
                          }).toList(),
                          onChanged: (String? newBreed) {
                            setState(() {
                              selectedBreed = newBreed;
                              print("Selected breed: $selectedBreed");
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Breed Type',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildBreedTypeOption("Cross Breed"),
                        _buildBreedTypeOption("Exotic"),
                        _buildBreedTypeOption("Indigenous"),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Body Color',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          hint: const Text("Select Body Color"),
                          value: selectedBodyColor,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          items: bodyColors.map((String color) {
                            return DropdownMenuItem<String>(
                              value: color,
                              child: Text(color),
                            );
                          }).toList(),
                          onChanged: (String? newColor) {
                            setState(() {
                              selectedBodyColor = newColor;
                              print("Selected body color: $selectedBodyColor");
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Horns',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Left Horn Dropdown
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                hint: const Text("Left Horn"),
                                value: selectedLeftHorn,
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down),
                                items: hornOptions.map((String horn) {
                                  return DropdownMenuItem<String>(
                                    value: horn,
                                    child: Text(horn),
                                  );
                                }).toList(),
                                onChanged: (String? newHorn) {
                                  setState(() {
                                    selectedLeftHorn = newHorn;
                                    print(
                                        "Selected left horn: $selectedLeftHorn");
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        // Right Horn Dropdown
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                hint: const Text("Right Horn"),
                                value: selectedRightHorn,
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down),
                                items: hornOptions.map((String horn) {
                                  return DropdownMenuItem<String>(
                                    value: horn,
                                    child: Text(horn),
                                  );
                                }).toList(),
                                onChanged: (String? newHorn) {
                                  setState(() {
                                    selectedRightHorn = newHorn;
                                    print(
                                        "Selected right horn: $selectedRightHorn");
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Switch of Tail',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          hint: const Text("Select Tail Color"),
                          value: selectedTailSwitch,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          items: tailSwitchOptions.map((String option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            );
                          }).toList(),
                          onChanged: (String? newState) {
                            setState(() {
                              selectedTailSwitch = newState;
                              print("Selected tail state: $selectedTailSwitch");
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Dropdown for Approximate Age
                    const Text(
                      'Approximate Age',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          hint: const Text("Select Age"),
                          value: selectedAge,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          items: List.generate(12, (index) => index + 1)
                              .map((age) {
                            return DropdownMenuItem<int>(
                              value: age,
                              child: Text("$age year${age > 1 ? 's' : ''}"),
                            );
                          }).toList(),
                          onChanged: (int? newAge) {
                            setState(() {
                              selectedAge = newAge;
                              print("Selected age: $selectedAge years");
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Dropdown for No of Lactation
                    const Text(
                      'No of Lactation',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          hint: const Text("Select Lactation"),
                          value: selectedLactation,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          items: List.generate(10, (index) => index)
                              .map((lactation) {
                            return DropdownMenuItem<int>(
                              value: lactation,
                              child: Text("$lactation"),
                            );
                          }).toList(),
                          onChanged: (int? newLactation) {
                            setState(() {
                              selectedLactation = newLactation;
                              print("Selected lactation: $selectedLactation");
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Dropdown for Calving Month
                    const Text(
                      'Calving (Month)',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          hint: const Text("Select Calving Month"),
                          value: selectedCalvingMonth,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          items:
                              List.generate(11, (index) => index).map((month) {
                            return DropdownMenuItem<int>(
                              value: month,
                              child: Text("$month"),
                            );
                          }).toList(),
                          onChanged: (int? newMonth) {
                            setState(() {
                              selectedCalvingMonth = newMonth;
                              print(
                                  "Selected calving month: $selectedCalvingMonth");
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Milk Yield/Day Button
                    const Text(
                      'Milk Yield (Liters/Day)',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          hint: const Text("Select Milk Yield"),
                          value: selectedMilkYield,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          items: List.generate(21, (index) => index)
                              .map((yieldValue) {
                            return DropdownMenuItem<int>(
                              value: yieldValue,
                              child: Text(
                                  "$yieldValue Liter${yieldValue > 1 ? 's' : ''}"),
                            );
                          }).toList(),
                          onChanged: (int? newYield) {
                            setState(() {
                              selectedMilkYield = newYield;
                              print(
                                  "Selected milk yield: $selectedMilkYield Liters/Day");
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Other Identification (Remarks) Button
                    // Inside your widget tree:
                    const Text(
                      'Other Identification (Remarks)',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isRemarksBoxVisible = !isRemarksBoxVisible;
                          print("Remarks box visibility: $isRemarksBoxVisible");
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        decoration: BoxDecoration(
                          color: isRemarksBoxVisible
                              ? Colors.brown
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.edit,
                                color: isRemarksBoxVisible
                                    ? Colors.white
                                    : Colors.black54),
                            const SizedBox(width: 10),
                            Text(
                              "Other Identification (Remarks)",
                              style: TextStyle(
                                color: isRemarksBoxVisible
                                    ? Colors.white
                                    : Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Text box appears when the remarks button is tapped
                    if (isRemarksBoxVisible)
                      TextField(
                        controller: remarksController,
                        decoration: InputDecoration(
                          labelText: "Enter Remarks",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                        maxLines: 3, // Allows for multiline input
                        onChanged: (value) {
                          print("Remarks entered: $value");
                        },
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => sendDataToBackend(context),
                      child: Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),

            // Third Tab - Image
            SingleChildScrollView(
              // Make the Image tab scrollable
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _pickImage(index),
                          child: Container(
                            color: Colors.grey[300],
                            child: _images[index] == null
                                ? const Center(child: Text('Pick Image'))
                                : Image.file(
                                    _images[index]!,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Videos',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(2, (index) {
                        return GestureDetector(
                          onTap: () => _pickVideo(index),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.45,
                            height: 200.0,
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _videos[index] == null
                                ? const Center(
                                    child: Text("Select/Record Video"))
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: AspectRatio(
                                      aspectRatio:
                                          _videos[index]!.value.aspectRatio,
                                      child: VideoPlayer(_videos[index]!),
                                    ),
                                  ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _uploadImagesAndVideos,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.brown,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
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

  Widget _buildSpeciesOption(String species, IconData icon) {
    final isSelected = selectedSpecies == species;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSpecies = species;
          selectedBreed = null; // Reset breed selection when species changes
          print("Selected species: $selectedSpecies");
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.brown : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.black54),
            const SizedBox(height: 5),
            Text(
              species,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHornOption(String label, IconData icon, bool isSelected,
      ValueChanged<bool> onSelected) {
    return GestureDetector(
      onTap: () {
        onSelected(!isSelected); // Toggle selection
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.brown : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.black54),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreedTypeOption(String breedType) {
    final isSelected = selectedBreedType == breedType;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedBreedType = breedType;
          print("Selected breed type: $selectedBreedType");
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.brown : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          breedType,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButton(
      {required String label, required IconData icon, required Color color}) {
    return GestureDetector(
      onTap: () {
        print("$label button tapped");
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
