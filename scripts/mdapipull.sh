echo "*** Creating PKG Directory ..."
mkdir mdapipkg

echo "*** pulling change set ..."
sfdx force:mdapi:retrieve -s -r ./mdapipkg -p "eWRTS" -u eWRTS -w 10

echo "*** Cleaning up ..."
cd mdapipkg
unzip ./unpackaged.zip -d ./
rm unpackaged.zip
cd ../

echo "*** Converting to source ..."
sfdx force:mdapi:convert -r ./mdapipkg/

echo "*** Removing pkg directory ..."
rm -r ./mdapipkg
