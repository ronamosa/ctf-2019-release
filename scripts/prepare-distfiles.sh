#!/bin/bash
# Prepare distfiles - collect all downloadable challenge files

set -e

echo "Preparing distfiles directory for CTF deployment..."

# Create distfiles directory
mkdir -p distfiles

# Copy challenge files for downloadable/forensics challenges

echo "Copying Network Analysis challenges..."
cp -v table-tennis/challenge/table-tennis.pcap distfiles/ 2>/dev/null || echo "  - table-tennis.pcap not found"
cp -v thekey/challenge/thekey.pcap distfiles/ 2>/dev/null || echo "  - thekey.pcap not found"
cp -v zippy/challenge/zippy.pcap distfiles/ 2>/dev/null || echo "  - zippy.pcap not found"

echo "Copying Forensics challenges..."
cp -v delta/challenge/*.png distfiles/ 2>/dev/null || echo "  - delta files not found"
cp -v diskimage/challenge/*.png distfiles/ 2>/dev/null || echo "  - diskimage files not found"
cp -v dawnupshaw/challenge/*.mp3 distfiles/ 2>/dev/null || echo "  - dawnupshaw files not found"
cp -v yayornay/challenge/*.db distfiles/ 2>/dev/null || echo "  - yayornay files not found"
cp -v weathercompanion/distfiles/*.apk distfiles/ 2>/dev/null || echo "  - weathercompanion files not found"
cp -v blink/challenge/*.apk distfiles/ 2>/dev/null || echo "  - blink files not found"

echo "Copying Reverse Engineering challenges..."
cp -v launchcode/challenge/*.exe distfiles/ 2>/dev/null || echo "  - launchcode files not found"
cp -v slashslash/challenge/*.zip distfiles/ 2>/dev/null || echo "  - slashslash files not found"
cp -v goodluks/challenge/goodluks distfiles/ 2>/dev/null || echo "  - goodluks files not found"
cp -v bWF0cnlvc2hrYQ/challenge/*.eml distfiles/ 2>/dev/null || echo "  - matryoshka files not found"

echo "Copying Crypto challenges..."
cp -v sendhalp/distfiles/* distfiles/ 2>/dev/null || echo "  - sendhalp files not found"

echo "Copying Other challenges..."
cp -v svgmagic/challenge/*.svg distfiles/ 2>/dev/null || echo "  - svgmagic files not found"
cp -v opendoor/challenge/* distfiles/ 2>/dev/null || echo "  - opendoor files not found"
cp -v dribbles/challenge/* distfiles/ 2>/dev/null || echo "  - dribbles files not found"
cp -v sequel/challenge/*.sql distfiles/ 2>/dev/null || echo "  - sequel files not found"

# Create index.html for file server
cat > distfiles/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>BSidesSF 2019 CTF - Challenge Files</title>
    <style>
        body {
            font-family: monospace;
            background: #1a1a1a;
            color: #00ff00;
            padding: 20px;
            max-width: 1000px;
            margin: 0 auto;
        }
        h1 {
            border-bottom: 2px solid #00ff00;
            padding-bottom: 10px;
        }
        .file-list {
            list-style: none;
            padding: 0;
        }
        .file-list li {
            padding: 8px;
            margin: 4px 0;
            background: #2a2a2a;
            border-left: 3px solid #00ff00;
        }
        .file-list a {
            color: #00ff00;
            text-decoration: none;
        }
        .file-list a:hover {
            color: #00ff00;
            text-decoration: underline;
        }
        .category {
            color: #ff6600;
            font-weight: bold;
            margin-top: 20px;
            font-size: 1.2em;
        }
    </style>
</head>
<body>
    <h1>BSidesSF 2019 CTF - Challenge Files</h1>
    <p>Download files for offline/forensics challenges</p>

    <div class="category">Network Analysis</div>
    <ul class="file-list">
        <li><a href="table-tennis.pcap">table-tennis.pcap</a></li>
        <li><a href="thekey.pcap">thekey.pcap</a></li>
        <li><a href="zippy.pcap">zippy.pcap</a></li>
    </ul>

    <div class="category">Forensics</div>
    <ul class="file-list">
        <li><a href="delta.png">delta.png</a></li>
        <li><a href="diskimage.png">diskimage.png</a></li>
        <li><a href="dawnupshaw.mp3">dawnupshaw.mp3</a></li>
        <li><a href="yayornay.db">yayornay.db</a></li>
        <li><a href="weathercompanion.apk">weathercompanion.apk</a></li>
        <li><a href="blink.apk">blink.apk</a></li>
    </ul>

    <div class="category">Reverse Engineering</div>
    <ul class="file-list">
        <li><a href="calc.exe">calc.exe (launchcode)</a></li>
        <li><a href="encrypted.zip">encrypted.zip (slashslash)</a></li>
        <li><a href="goodluks">goodluks</a></li>
        <li><a href="email.eml">email.eml (matryoshka)</a></li>
    </ul>

    <div class="category">Cryptography</div>
    <ul class="file-list">
        <li><a href="encrypted_file.enc">encrypted_file.enc (sendhalp)</a></li>
    </ul>

    <div class="category">Other</div>
    <ul class="file-list">
        <li><a href="magic.svg">magic.svg (svgmagic)</a></li>
    </ul>
</body>
</html>
EOF

# List all files
echo ""
echo "Distfiles directory contents:"
ls -lh distfiles/

echo ""
echo "Done! Distfiles are ready in ./distfiles/"
echo "You can now start the file server with: docker-compose up -d fileserver"
