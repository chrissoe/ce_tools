# ce_tools
batch script updating the version control, copying all files into one directory and pack it into .pak files.

If you don't want to use SVN just comment line 56 - 59 out or write the integration for your version control system :)

##Requirements (Software)
WinRar

CryEngine's RC Tool

BeyondCompare (free version will work too)

## CreateBuild.bat
As the script isn't polished until now, but I wanted to release it as early as possible there can be bugs.
For better understanding I will publish my folder structure:

|-MainFolder (doesn't matter)

    |-BuildArchive
    |-BuildScripts (i got more than one - put the scripts in here [CreateBuild.bat] etc.)
    |-SVN (that's for our clean repository - get's updated using the script)
      |-yourprojectname

##CopyBuildScript.txt
This one will be used by BeyondCompare and will copy files over to the temp processing folder with your filters applied.

The filters will be found inside the CopyBuildScript.txt. You can normally change it as you wish without breaking anything.
