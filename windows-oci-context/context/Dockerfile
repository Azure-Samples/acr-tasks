# escape=`
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Copy a simple text file into the image
COPY hello.txt C:\hello.txt

# When the container runs, display the contents of hello.txt
CMD ["cmd", "/c", "type C:\\hello.txt && timeout /t 10"]

