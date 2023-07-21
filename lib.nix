let
  passEntryCommand = entry: "pass show ${entry}";
  passEntryFieldCommand = entry: field: "${passEntryCommand entry} | sed -n 's/${field}: //p'";
  passMailCommand = address: passEntryFieldCommand "Mail/${address}" "apppass";
  mkEmailAccount = {
    userName,
    realName,
    address,
    imap,
    smtp,
    passwordCommand,
    primary ? false,
  }: {
    inherit userName realName address imap smtp primary passwordCommand;

    himalaya.enable = true;
    himalaya.settings.sync = true;
    himalaya.settings.imap-auth = "passwd";
    himalaya.settings.imap-passwd.cmd = passwordCommand;
  };
  mkGmailAccount = {
    userName,
    realName,
    primary ? false,
  }:
    (mkEmailAccount {
      inherit userName realName primary;
      address = userName;
      imap.host = "imap.gmail.com";
      smtp.host = "smtp.gmail.com";
      passwordCommand = passMailCommand userName;
    })
    // {
      flavor = "gmail.com";
    };
in {
  inherit mkEmailAccount mkGmailAccount;
  inherit passEntryCommand passEntryFieldCommand passMailCommand;
}
