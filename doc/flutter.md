# flutter

## build

`flutter build apk --split-per-abi`

## widget的状态

有/无状态的widget：（stateful/stateless）指widget是否需要跟随指定条件而变化（例如用户输入）  
无状态的widget不会变化；有状态的widget需要关联其他对象来构建：
```flutter
class MyCounter extends StatefulWidget {
  const MyCounter({super.key});

  @override
  State<MyCounter> createState() => _MyCounterState();
}

class _MyCounterState extends State<MyCounter> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $count'),
        TextButton(
          onPressed: () {
            setState(() {
              count++;
            });
          },
          child: Text('Increment'),
        )
      ],
    );
  }
}
```

## widget状态管理

父子widget间共享状态：创建子widget时传入变量（使用widget构造函数）

ChangeNotifier:
```flutter
class CounterNotifier extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }
}

// 调用
Column(
  children: [
    ListenableBuilder(
      listenable: counterNotifier,
      builder: (context, child) {
        return Text('counter: ${counterNotifier.count}');
      },
    ),
    TextButton(
      child: Text('Increment'),
      onPressed: () {
        counterNotifier.increment();
      },
    ),
  ],
)
```

MVVM：数据与UI分开
```flutter
ListenableBuilder(
  listenable: viewModel,
  builder: (context, child) {
```
