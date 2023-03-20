import { FairyEditor } from 'csharp';
import CodeWriter from './CodeWriter';

function capitalizeFirstLetter(str: string): string {
  return str.charAt(0).toUpperCase() + str.slice(1);
}

function uncapitalizeFirstLetter(str: string): string {
  return str.charAt(0).toLowerCase() + str.slice(1);
}

function genCode(handler: FairyEditor.PublishHandler) {
    let settings = (<FairyEditor.GlobalPublishSettings>handler.project.GetSettings("Publish")).codeGeneration;
    let codePkgName = handler.ToFilename(handler.pkg.name); //convert chinese to pinyin, remove special chars etc.
    let exportCodePath = handler.exportCodePath + '/' + codePkgName;
    let namespaceName = uncapitalizeFirstLetter(codePkgName);

    if (settings.packageName)
        namespaceName = uncapitalizeFirstLetter(settings.packageName) + '.' + uncapitalizeFirstLetter(namespaceName);

    //CollectClasses(stripeMemeber, stripeClass, fguiNamespace)
    let classes = handler.CollectClasses(settings.ignoreNoname, settings.ignoreNoname, null);
    handler.SetupCodeFolder(exportCodePath, "hx"); //check if target folder exists, and delete old files

    let getMemberByName = settings.getMemberByName

    let classCnt = classes.Count;
    let writer = new CodeWriter();	
	writer.blockFromNewLine = false;
    for (let i: number = 0; i < classCnt; i++) {
        let classInfo = classes.get_Item(i);
        let members = classInfo.members;
        writer.reset();

        writer.writeln('package %s;', namespaceName);
        writer.writeln('import hxPEngine.ui.component.*;');
        writer.writeln('import hxPEngine.ui.utils.*;');
        writer.writeln();
        writer.writeln('class %s extends %s', capitalizeFirstLetter(classInfo.className), classInfo.superClassName);
        writer.startBlock();

        let memberCnt = members.Count
        for (let j: number = 0; j < memberCnt; j++) {
            let memberInfo = members.get_Item(j);
            writer.writeln('public var %s:%s;', memberInfo.varName, memberInfo.type);
        }
        writer.writeln('public static inline var URL:String = "ui://%s%s";', handler.pkg.id, classInfo.resId);
        writer.writeln();

        writer.writeln('public static function createInstance():%s', capitalizeFirstLetter(classInfo.className));
        writer.startBlock();
        writer.writeln('return cast(UIPackage.createObject("%s", "%s"), %s);', handler.pkg.name, classInfo.resName, capitalizeFirstLetter(classInfo.className));
        writer.endBlock();
        writer.writeln();

        writer.writeln('private override function constructFromXML(xml:haxe.xml.Access):Void');
        writer.startBlock();
        writer.writeln('super.constructFromXML(xml);');
        writer.writeln();
        for (let j: number = 0; j < memberCnt; j++) {
            let memberInfo = members.get_Item(j);
            if (memberInfo.group == 0) {
                if (getMemberByName)
                    writer.writeln('%s = cast(this.getChild("%s"), %s);', memberInfo.varName, memberInfo.name, memberInfo.type);
                else
                    writer.writeln('%s = cast(this.getChildAt(%s), %s);', memberInfo.varName, memberInfo.index, memberInfo.type);
            }
            else if (memberInfo.group == 1) {
                if (getMemberByName)
                    writer.writeln('%s = this.getController("%s");', memberInfo.varName, memberInfo.name);
                else
                    writer.writeln('%s = this.getControllerAt(%s);', memberInfo.varName, memberInfo.index);
            }
            else {
                if (getMemberByName)
                    writer.writeln('%s = this.getTransition("%s");', memberInfo.varName, memberInfo.name);
                else
                    writer.writeln('%s = this.getTransitionAt(%s);', memberInfo.varName, memberInfo.index);
            }
        }
        writer.endBlock();

        writer.endBlock(); //class

        writer.save(exportCodePath + '/' + capitalizeFirstLetter(classInfo.className) + '.hx');
    }

    writer.reset();

    let binderName = capitalizeFirstLetter(codePkgName) + 'Binder';

    writer.writeln('package %s;', namespaceName);
    writer.writeln('import hxPEngine.ui.utils.*;');
    writer.writeln();
    writer.writeln('class %s', binderName);
    writer.startBlock();

    writer.writeln('public static function bindAll():Void');
    writer.startBlock();
    for (let i: number = 0; i < classCnt; i++) {
        let classInfo = classes.get_Item(i);
        writer.writeln('UIObjectFactory.setPackageItemExtension(%s.URL, cast %s);', capitalizeFirstLetter(classInfo.className), capitalizeFirstLetter(classInfo.className));
    }
    writer.endBlock(); //bindall

    writer.endBlock(); //class

    writer.save(exportCodePath + '/' + binderName + '.hx');
}

export { genCode };