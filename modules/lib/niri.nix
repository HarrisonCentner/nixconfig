{
  _module.args.blockOutFromScreencast = appIds: [
    {
      matches = map (appId: { app-id = appId; }) appIds;
      block-out-from = "screencast";
    }
  ];
}
