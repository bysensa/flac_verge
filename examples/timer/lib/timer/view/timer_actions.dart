import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../timer.dart';

class TimerActions extends StatelessWidget {
  const TimerActions({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerStore, TimerState>(
      buildWhen: (prev, state) => prev != state,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (state.status == TimerStatus.initial) ...[
              FloatingActionButton(
                child: const Icon(Icons.play_arrow),
                onPressed: () => context.read<TimerStore>().start(),
              ),
            ],
            if (state.status == TimerStatus.inProgress) ...[
              FloatingActionButton(
                child: const Icon(Icons.pause),
                onPressed: () => context.read<TimerStore>().pause(),
              ),
              FloatingActionButton(
                child: const Icon(Icons.replay),
                onPressed: () => context.read<TimerStore>().reset(),
              ),
            ],
            if (state.status == TimerStatus.pause) ...[
              FloatingActionButton(
                child: const Icon(Icons.play_arrow),
                onPressed: () => context.read<TimerStore>().resume(),
              ),
              FloatingActionButton(
                child: const Icon(Icons.replay),
                onPressed: () => context.read<TimerStore>().reset(),
              ),
            ],
            if (state.status == TimerStatus.complete) ...[
              FloatingActionButton(
                child: const Icon(Icons.replay),
                onPressed: () => context.read<TimerStore>().reset(),
              ),
            ]
          ],
        );
      },
    );
  }
}
