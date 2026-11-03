part of '../../app_router.dart';

const testerBranch = TypedStatefulShellBranch<TesterBranch>(routes: [TypedGoRoute<TesterRoute>(path: '/tester')]);

class TesterBranch extends StatefulShellBranchData {
  const TesterBranch();
}

class TesterRoute extends GoRouteData with $TesterRoute {
  const TesterRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const TesterScreen();
}
