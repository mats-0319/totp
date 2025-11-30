import 'package:flutter/material.dart';

import 'package:totp/components/dotted_line.dart';
import 'package:totp/widgets/dialog_operate_instance.dart';

class EmptyKeyInstance extends StatelessWidget {
  const EmptyKeyInstance({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(28),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) =>
                OperateInstanceDialog(operate: Operate.create),
          );
        },
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: DashedRect(
                color: Theme.of(context).colorScheme.secondary,
                strokeWidth: 1.0,
                gap: 6.0,
              ),
            ),
            Center(
              child: IconTheme(
                data: IconThemeData(size: 72, opacity: 0.3),
                child: Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
