This is a script that will generate the MD5 value for the 10mb chunks for a package that you intended to install during Setup assistant.
10mb chunks is a Apple Requirement, the script will already do this. In the sample all you need to do is update the URL key with the hosting url of the package

In the md5s key / array is where you put the output of the script minus the starting 0 1 2 3. This was added into the script so you can know how many strings you need to add into the array.

An example of the output is

0 477df1aa5ccd32c42ff3edf7731be5fd
1 535afd7b4c65a2b88bdb5f18e8214d17
2 caa2acd7cf8c78d146947c12e8e0d5b3

So the array will look like
##
<key>md5s</key>
<array>
<string>477df1aa5ccd32c42ff3edf7731be5fd</string>
<string>535afd7b4c65a2b88bdb5f18e8214d17</string>
<string>caa2acd7cf8c78d146947c12e8e0d5b3</string>
</array>
##

So we dropped the begining digit. All you need to do is upload this mainifest to your jamf pro server in the Settings > Packages > The targeted package. Then if your share meets the requirments for pre-stage install and the package meets the requirments. the package will install. 


#
The world is mean be nice to each other
