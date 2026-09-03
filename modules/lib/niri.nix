{
  _module.args.blockOutFromScreencast = appIds: [
    {
      window-rule._children = (map (appId: { match._props.app-id = appId; }) appIds) ++ [
        { block-out-from = "screencast"; }
      ];
    }
  ];
}
