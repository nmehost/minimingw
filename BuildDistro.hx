import sys.FileSystem;

class BuildDistro
{
   static var checked = new Map<String,Bool>();

   public static function createDirectory(inName:String)
   {
      if (checked.exists(inName))
         return;

      checked.set(inName,true);
      if (!FileSystem.exists(inName))
      {
         Sys.println("createDirectory " + inName);
         FileSystem.createDirectory(inName);
      }
   }

   public static function copyRecurse(fromDir:String, toDir:String, file:String)
   {
      var src = fromDir + "/" + file;
      if (!FileSystem.exists(src))
         throw "File does not exist:" + src;

      var dest = toDir +"/" + file;
      var parts = dest.split("/");
      for(subDir in 1...parts.length)
         createDirectory(parts.slice(0,subDir).join("/"));

      if (FileSystem.isDirectory(src))
      {
          for(child in FileSystem.readDirectory(src))
          {
             if (child.substr(0,1)!=".")
                copyRecurse(src, dest, child);
          }
      }
      else
      {
         Sys.println("copy " + src + " -> " + dest);
         sys.io.File.copy(src,dest);
      }
   }

   public static function main()
   {
      var mingwSrc = "c:/MinGW";
      var mingwVersion = "4.8.1";

      var arg = Sys.args()[0];
      if (arg!=null && arg!="")
         mingwSrc = arg;

      var arg = Sys.args()[1];
      if (arg!=null && arg!="")
         mingwVersion = arg;

      try
      {
         var files = sys.io.File.getContent("files.txt");
         for(file in files.split("\n"))
            if (file.length>0 && file.substr(0,1)!="#")
               copyRecurse(mingwSrc,"MinGW",file.split("{VERSION}").join(mingwVersion));

         for(file in ["haxelib.json", "Changes.md"] )
            copyRecurse(".","MinGW",file);
      }
      catch(e:Dynamic)
      {
         Sys.println("Could not copy files : " + e);
         Sys.exit(-1);
      }
   }
}
