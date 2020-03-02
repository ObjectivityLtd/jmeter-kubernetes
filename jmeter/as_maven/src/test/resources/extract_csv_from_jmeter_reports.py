import zipfile36 as zipfile

archive = zipfile.ZipFile('tmp/23.zip', 'r')
imgfile = archive.open('img_01.png')
