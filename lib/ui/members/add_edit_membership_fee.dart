/*
 * Copyright (c) 2024 by Yann39.
 *
 * This file is part of CCTeam application.
 *
 * CCTeam is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * CCTeam is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with CCTeam. If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:ccteam/models/member.dart';
import 'package:ccteam/models/membership_fee.dart';
import 'package:ccteam/providers/member_detail_provider.dart';
import 'package:ccteam/providers/message_provider.dart';
import 'package:ccteam/services/members_service.dart';
import 'package:ccteam/utils/constants.dart';
import 'package:ccteam/utils/custom_decorations.dart';
import 'package:ccteam/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddEditMembershipFee extends StatefulWidget {
  @override
  _AddEditMembershipFeeState createState() => _AddEditMembershipFeeState();
}

class _AddEditMembershipFeeState extends State<AddEditMembershipFee> {
  final _formKey = GlobalKey<FormState>();
  final MembersService _membersService = MembersService();

  bool _isLoading = false;
  Member? _member;
  MembershipFee? _fee;

  int? _year;
  double? _amount;
  bool _paid = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _member = args['member'] as Member?;
      _fee = args['fee'] as MembershipFee?;

      if (_fee != null && _year == null) {
        _year = _fee!.year;
        _amount = _fee!.amount;
        _paid = _fee!.paid ?? false;
      } else if (_year == null) {
        _year = DateTime.now().year;
        _amount = 0.0;
        _paid = false;
      }
    }
  }

  void _saveFee() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      try {
        if (_fee == null) {
          // Add new fee
          await _membersService.addMembershipFee(_member!.id!, _year!, _amount!, _paid);
        } else {
          // Update existing fee
          await _membersService.updateMembershipFee(_fee!.id!, _year!, _amount!, _paid);
        }

        // Refresh member details
        await Provider.of<MemberDetailProvider>(context, listen: false).refreshCurrentMember();

        Navigator.of(context).pop("Cotisation enregistrée avec succès");
      } catch (e) {
        Provider.of<MessageProvider>(context, listen: false).setMessage("Erreur lors de l'enregistrement: $e", MessageType.ERROR);
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _deleteFee() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Confirmation"),
        content: Text("Voulez-vous vraiment supprimer cette cotisation ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              setState(() {
                _isLoading = true;
              });
              try {
                await _membersService.deleteMembershipFee(_fee!.id!);
                await Provider.of<MemberDetailProvider>(context, listen: false).refreshCurrentMember();
                Navigator.of(context).pop("Cotisation supprimée avec succès");
              } catch (e) {
                Provider.of<MessageProvider>(context, listen: false).setMessage("Erreur lors de la suppression: $e", MessageType.ERROR);
                setState(() {
                  _isLoading = false;
                });
              }
            },
            child: Text("Supprimer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_fee == null ? "Ajouter une cotisation" : "Modifier la cotisation"),
        actions: [
          if (_fee != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteFee,
            )
        ],
      ),
      body: Container(
        decoration: CustomDecorations.mainContent,
        padding: const EdgeInsets.all(UI_FORM_PADDING),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _year?.toString() ?? '',
                      decoration: InputDecoration(
                        labelText: 'Année',
                        icon: Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une année';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Veuillez entrer une année valide';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _year = int.parse(value!);
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      initialValue: _amount?.toString() ?? '',
                      decoration: InputDecoration(
                        labelText: 'Montant (€)',
                        icon: Icon(Icons.euro),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un montant';
                        }
                        if (double.tryParse(value.replaceAll(',', '.')) == null) {
                          return 'Veuillez entrer un montant valide';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _amount = double.parse(value!.replaceAll(',', '.'));
                      },
                    ),
                    SizedBox(height: 16),
                    SwitchListTile(
                      title: Text('Payée ?'),
                      value: _paid,
                      onChanged: (bool value) {
                        setState(() {
                          _paid = value;
                        });
                      },
                      secondary: Icon(Icons.payment),
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveFee,
                      child: Text('Enregistrer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
