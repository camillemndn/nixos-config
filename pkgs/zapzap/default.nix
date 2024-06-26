{
  lib,
  python3,
  fetchFromGitHub,
  qt6,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "zapzap";
  version = "4.5.2";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "rafatosta";
    repo = "zapzap";
    rev = "v${version}";
    hash = "sha256-D2R5F4PeKTpeSYyy56aTnh/9CJSP4qtmCpWyoBNqrk4=";
  };

  patches = [ ./remove_makedirs.patch ];

  nativeBuildInputs = [ qt6.wrapQtAppsHook ];

  buildInputs = [ qt6.qtwayland ];

  propagatedBuildInputs = with python3.pkgs; [
    pyqt6
    pyqt6-webengine
    pydbus
  ];

  postInstall = ''
    cp -r share $out
  '';

  pythonImportsCheck = [ "zapzap" ];

  meta = with lib; {
    description = "WhatsApp desktop application written in Pyqt6 + PyQt6-WebEngine";
    homepage = "https://github.com/rafatosta/zapzap";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ camillemndn ];
    platforms = platforms.linux;
  };
}
