FROM mcr.microsoft.com/dotnet/sdk:9.0
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/ss14/run/Robust.Server", "--data-dir", "/ss14/data"]
RUN groupadd -r -g 1000 ss14 && useradd -ms /bin/bash ss14 -d /ss14 -u 1000 -g 1000
RUN apt-get -y update && apt-get -y install curl unzip wget python3 git
WORKDIR /ss14
RUN echo '#!/bin/bash\n\
echo Pulling patches &&\
cd /ss14/patches &&\
git init &&\
git config remote.origin.url >&- || \
git remote add origin https://github.com/atakku/fem.station &&\
git remote set-url origin https://github.com/atakku/fem.station &&\
git fetch origin &&\
git reset --hard origin/main &&\
git clean -xdf &&\
echo Pulling source &&\
cd /ss14/src &&\
git init &&\
git config remote.origin.url >&- || \
git remote add origin https://github.com/space-wizards/space-station-14 &&\
git remote set-url origin https://github.com/space-wizards/space-station-14 &&\
git fetch origin &&\
git reset --hard origin/master &&\
git clean -xdf &&\
echo Applying patches &&\
git apply /ss14/patches/patches/*.diff &&\
echo Running build &&\
python3 RUN_THIS.py &&\
dotnet restore &&\
dotnet build Content.Packaging --configuration Release --no-restore /m &&\
dotnet run --project Content.Packaging server --hybrid-acz --platform linux-x64 --platform win-x64 &&\
echo Cleaning run folder &&\
rm -rf /ss14/run/* &&\
unzip release/SS14.Server_linux-x64.zip -d /ss14/run &&\
chmod +x /ss14/run/Robust.Server &&\
echo Starting up &&\
$@' >> /entrypoint.sh && chmod +x /entrypoint.sh
WORKDIR /ss14/run
USER ss14