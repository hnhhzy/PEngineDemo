function capitalizeFirstLetter(str)
  return str:gsub("^%l", string.upper)
end

function uncapitalizeFirstLetter(str)
  return str:gsub("^%u", string.lower)
end

local function genCode(handler)
    local settings = handler.project:GetSettings("Publish").codeGeneration
    local codePkgName = handler:ToFilename(handler.pkg.name); --convert chinese to pinyin, remove special chars etc.
    local exportCodePath = handler.exportCodePath..'/'..codePkgName
    local namespaceName = uncapitalizeFirstLetter(codePkgName)
    
    if settings.packageName~=nil and settings.packageName~='' then
        namespaceName = uncapitalizeFirstLetter(settings.packageName)..'.'..uncapitalizeFirstLetter(namespaceName);
    end

    --CollectClasses(stripeMemeber, stripeClass, fguiNamespace)
    local classes = handler:CollectClasses(settings.ignoreNoname, settings.ignoreNoname, nil)
    handler:SetupCodeFolder(exportCodePath, "hx") --check if target folder exists, and delete old files

    local getMemberByName = settings.getMemberByName

    local classCnt = classes.Count
    local writer = CodeWriter.new()
	writer.blockFromNewLine = false;
    for i=0,classCnt-1 do
        local classInfo = classes[i]
        local members = classInfo.members
        writer:reset()

        writer:writeln('package %s;', namespaceName)
        writer:writeln('import hxPEngine.ui.component.*;')
        writer:writeln('import hxPEngine.ui.utils.*;')
        writer:writeln()
        writer:writeln('class %s extends %s', capitalizeFirstLetter(classInfo.className), classInfo.superClassName)
        writer:startBlock()

        local memberCnt = members.Count
        for j=0,memberCnt-1 do
            local memberInfo = members[j]
            writer:writeln('public var %s:%s;', memberInfo.varName, memberInfo.type)
        end
        writer:writeln('public static inline var URL:String = "ui://%s%s";', handler.pkg.id, classInfo.resId)
        writer:writeln()

        writer:writeln('public static function createInstance():%s', capitalizeFirstLetter(classInfo.className))
        writer:startBlock()
        writer:writeln('return cast(UIPackage.createObject("%s", "%s"), %s);', handler.pkg.name, classInfo.resName, capitalizeFirstLetter(classInfo.className))
        writer:endBlock()
        writer:writeln()

        writer:writeln('private override function constructFromXML(xml:haxe.xml.Access):Void')
        writer:startBlock()
        writer:writeln('super.constructFromXML(xml);')
        writer:writeln()
        for j=0,memberCnt-1 do
            local memberInfo = members[j]
            if memberInfo.group==0 then
                if getMemberByName then
                    writer:writeln('%s = cast(this.getChild("%s"), %s);', memberInfo.varName, memberInfo.name, memberInfo.type)
                else
                    writer:writeln('%s = cast(this.getChildAt(%s), %s);', memberInfo.varName, memberInfo.index, memberInfo.type)
                end
            elseif memberInfo.group==1 then
                if getMemberByName then
                    writer:writeln('%s = this.getController("%s");', memberInfo.varName, memberInfo.name)
                else
                    writer:writeln('%s = this.getControllerAt(%s);', memberInfo.varName, memberInfo.index)
                end
            else
                if getMemberByName then
                    writer:writeln('%s = this.getTransition("%s");', memberInfo.varName, memberInfo.name)
                else
                    writer:writeln('%s = this.getTransitionAt(%s);', memberInfo.varName, memberInfo.index)
                end
            end
        end
        writer:endBlock()

        writer:endBlock() --class

        writer:save(exportCodePath..'/'..capitalizeFirstLetter(classInfo.className)..'.hx')
    end

    writer:reset()

    local binderName = capitalizeFirstLetter(codePkgName)..'Binder'

    writer:writeln('package %s;', namespaceName)
    writer:writeln('import hxPEngine.ui.utils.*;')
    writer:writeln()
    writer:writeln('class %s', binderName)
    writer:startBlock()

    writer:writeln('public static function bindAll():Void')
    writer:startBlock()
    for i=0,classCnt-1 do
        local classInfo = classes[i]
        writer:writeln('UIObjectFactory.setPackageItemExtension(%s.URL, cast %s);', capitalizeFirstLetter(classInfo.className), capitalizeFirstLetter(classInfo.className))
    end
    writer:endBlock() --bindall

    writer:endBlock() --class
    
    writer:save(exportCodePath..'/'..binderName..'.hx')
end

return genCode