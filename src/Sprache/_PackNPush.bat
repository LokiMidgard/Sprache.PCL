REM
    @echo off
	set _fault=0

	rem ---------- foreach csproj file ----------
    for %%p in (*.csproj) do call :packpushproj %%p
    goto :end

:packpushproj
	if %_fault% NEQ 0 goto :end
	echo Processing %1 ...

	rem ---------- prep ----------
	call :check_count *.nupkg 0 warn_clean
	if %_fault% NEQ 0 goto :end

	rem delete old .nupkg files
    for %%f in (*.nupkg) do del /f %%f

	call :check_count *.nupkg 0 error_clean
	if %_fault% NEQ 0 goto :end

	rem ---------- pack ----------
    echo Packing %1 ...
	..\.nuget\nuget.exe pack %1 -IncludeReferencedProjects -Prop Configuration=Release

	call :check_count *.nupkg 1 error_pack
	if %_fault% NEQ 0 goto :end

    rem ---------- push ----------
    for %%f in (*.nupkg) do call :pushpkg %%f
    goto :end

:pushpkg
	if %_fault% NEQ 0 goto :end

    echo Setting API key API key [%nugetApiKey%]
    ..\.nuget\nuget.exe setApiKey %nugetApiKey%

    echo Pushing %1 ...
    ..\.nuget\nuget.exe push %1
    pause

    echo Deleting %1 ...
	del %1
    goto :end

:check_count
	call :count %1 
	if %_count% EQU %2 goto :end
    goto :%3
	goto :end

:count
    set /a _count = 0
	for %%x in (%1) do call :inc_count
    goto :end

:inc_count
    set /a _count = %_count% + 1
    goto :end

:warn_clean
	echo Deleting %_count% old .nupkg files...
	goto :end

:error_clean
	set _fault=1
	echo Failed to delete old .nupkg files.
	pause
	goto :end

:error_pack
	set _fault=1
    echo Packed failed: %_count% .nupkg files were found.
	pause
	goto :end

:end
    rem pause 
