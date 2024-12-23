import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_browser/Db/hive_db_helper.dart';
import 'package:flutter_browser/rss_news/utils/show_snackbar.dart';

import '../models/rules_model.dart';

class RulesWidget extends StatefulWidget {
  const RulesWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RulesWidgetState createState() => _RulesWidgetState();
}

class _RulesWidgetState extends State<RulesWidget> {
  void showAddingDialog({
    int? editIndex,
  }) {
    String? ruleType;
    String? ruleCategory;
    String? ruleValue;
    String? websiteDomainValue;

    if (editIndex != null) {
      Rules rule = HiveDBHelper.getRuleAtIndex(editIndex);
      ruleType = rule.type;
      ruleCategory = rule.category;
      ruleValue = rule.value;
      websiteDomainValue = rule.domain;
    }
    TextEditingController ruleTypeController =
        TextEditingController(text: ruleValue);
    TextEditingController websiteDomainController =
        TextEditingController(text: websiteDomainValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(editIndex != null ? "Edit Rule" : "Add Rule"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: ruleCategory,
              items: const [
                DropdownMenuItem(
                  value: "AdBlock",
                  child: Text("Adblock"),
                ),
                DropdownMenuItem(
                  value: "Immersive Reader",
                  child: Text("Immersive Reader"),
                ),
              ],
              onChanged: (String? value) {
                ruleCategory = value!;
              },
              decoration: const InputDecoration(labelText: "Rule Category"),
            ),
            DropdownButtonFormField<String>(
              value: ruleType,
              items: const [
                DropdownMenuItem(
                  value: "Class",
                  child: Text("Class"),
                ),
                DropdownMenuItem(
                  value: "Id",
                  child: Text("Id"),
                ),
              ],
              onChanged: (String? value) {
                ruleType = value!;
              },
              decoration: const InputDecoration(labelText: "Rule Type"),
            ),
            TextField(
              onChanged: (value) => ruleValue = value,
              controller: ruleTypeController,
              decoration: const InputDecoration(labelText: "Class or Id"),
            ),
            TextField(
              onChanged: (value) => websiteDomainValue = value,
              controller: websiteDomainController,
              decoration: const InputDecoration(labelText: "Website Domain"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (ruleCategory == null ||
                  ruleType == null ||
                  ruleValue == null ||
                  websiteDomainValue == null) {
                // If any field is empty, show an error or do not allow saving
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Error"),
                    content: const Text("All fields are required."),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the error dialog
                        },
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );
              } else {
                if (editIndex != null) {
                  // If editing, update the rule at the editIndex
                  await HiveDBHelper.removeRule(editIndex);
                  await HiveDBHelper.addRule(Rules(
                    category: ruleCategory!,
                    type: ruleType!,
                    value: ruleValue!,
                    domain: websiteDomainValue!,
                  ));
                } else {
                  await HiveDBHelper.addRule(Rules(
                    category: ruleCategory!,
                    type: ruleType!,
                    value: ruleValue!,
                    domain: websiteDomainValue!,
                  ));
                }
                // debugPrint(rules.toString());
                Navigator.pop(context);
              }
            },
            child: Text(editIndex != null ? "Save" : "Add"),
          ),
          if (editIndex != null)
            TextButton(
              onPressed: () async {
                await HiveDBHelper.removeRule(editIndex);
                Navigator.pop(context);
              },
              // Disable the button if editIndex is null
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            )
        ],
      ),
    );
  }

  List<Widget> showRules() {
    final rules = HiveDBHelper.getAllRules();
    if (rules.isNotEmpty) {
      return rules.asMap().entries.map((entry) {
        final index = entry.key; // Get index of the rule
        final rule = entry.value; // Get the actual rule object
        return ListTile(
          title: Text("${rule.value} - ${rule.domain}"), // Use rule properties
          onTap: () {
            Navigator.pop(context); // Close the dialog
            showAddingDialog(
              editIndex: index,
            );
          },
        );
      }).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final rules = HiveDBHelper.getAllRules();
    return Column(
      children: [
        ListTile(
          title: const Text(
            "Create and Manage Rules",
          ),
          subtitle: const Text(
              "Set rules for Ads Block or Immersive Reader on specific domains"),
          trailing: Wrap(
            spacing: 12,
            children: [
              IconButton(
                icon: const Icon(Icons.add, color: Colors.green),
                onPressed: showAddingDialog,
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  if (rules.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Choose a Rule to Edit"),
                        content: SizedBox(
                          height: 300.0, // Adjust height as needed
                          width: double.maxFinite,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [...showRules()],
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    showSnackBar(
                      message: "No rules to edit",
                    );
                  }
                },
              )
            ],
          ),
        ),
      ],
    );
  }
}
