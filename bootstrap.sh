NAME=Notes
URL=https://www.icloud.com/notes
# ICON_PNG_URL is optional and nativefier will guess if not set
ICON_PNG_URL=https://support.apple.com/library/content/dam/edam/applecare/images/en_US/social/thumbnail/ios11-notes-icon_2x.png
DESCRIPTION=Social

# Inject css into app
# Unsure if works or not
cat << "EOF" > /tmp/inject.css

EOF

# Inject js into app
# note: this works, but I've noticed that the app stuggles to
# detect/pickup changes if you re-install the app with diff
# js
cat << "EOF" > /tmp/inject.js
const css = `
body {filter: invert();}	
`
var s = document.createElement('style');
s.innerHTML = css;
document.head.appendChild(s);
EOF

mkdir apps &> /dev/null
cd apps
rm -rf "$NAME" &> /dev/null

npx nativefier "$URL" --single-instance --name "$NAME" --inject /tmp/inject.css --inject /tmp/inject.js
mv "$NAME-linux-x64" "$NAME"

if [ -n "$ICON_PNG_URL" ]; then
	ehco OVERRIDE
	curl -o "$NAME/resources/app/icon.png" "$ICON_PNG_URL"
fi

cp ../bootstrap.sh "$NAME/"
echo "[Desktop Entry]
Type=Application
Version=1.0
Name=$NAME
Comment=$DESCRIPTION
Exec=/usr/local/lib/$NAME/$NAME
Icon=/usr/local/lib/$NAME/resources/app/icon.png
StartupWMClass=`jq -r '.name' "$NAME/resources/app/package.json"`
Terminal=false
Categories=GTK
MimeType=text/html;text/xml;application/xhtml_xml;
" > "$NAME"/"$NAME".desktop
chmod +x "$NAME"/"$NAME".desktop
sudo rm -rf "/usr/local/lib/$NAME" &> /dev/null
sudo cp -rf "$NAME" "/usr/local/lib/"
sudo mkdir /usr/local/share/applications &> /dev/null
sudo cp "$NAME/$NAME.desktop" /usr/local/share/applications/
