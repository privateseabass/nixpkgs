{ stdenv, fetchurl, tcl, tk, tcllib, tcltls, bwidget, cacert, makeWrapper, x11 }:

stdenv.mkDerivation rec {
  name = "tkabber-0.11.1";

  src = fetchurl {
    url = "http://files.jabber.ru/tkabber/tkabber-0.11.1.tar.gz";
    sha256 = "19xv555cm7a2gczdalf9srxm39hmsh0fbidhwxa74a89nqkbf4lv";
  };

  defaultTheme = "ocean-deep";

  patchPhase = ''
    substituteInPlace login.tcl --replace \
      "custom::defvar loginconf(sslcacertstore) \"\"" \
      "custom::defvar loginconf(sslcacertstore) \"${cacert}/etc/ca-bundle.crt\""

    sed -i '/^if.*load_default_xrdb/,/^}$/ {
        s@option readfile \(\[fullpath [^]]*\]\)@option readfile "'"$out/share/doc/tkabber/examples/xrdb/${defaultTheme}.xrdb"'"@
    }' tkabber.tcl
  '';

  configurePhase = ''
    mkdir -p $out/bin
    sed -e "s@/usr/local@$out@" -i Makefile
  '';

  postInstall = ''
    wrapProgram $out/bin/tkabber --set TCLLIBPATH "${bwidget}/lib/${bwidget.libPrefix}\ ${tcllib}/lib/${tcllib.libPrefix}\ ${tcltls}/lib/${tcltls.libPrefix}"
  '';

  buildInputs = [ tcl tk tcllib tcltls bwidget x11 makeWrapper ];

  meta = {
    homepage = "http://tkabber.jabber.ru/";
    description = "A GUI client for the XMPP (Jabber) instant messaging protocol";
  };
}
