import asyncio
import ssl

async def main():
    loop = asyncio.get_running_loop()
    ssl_context = ssl.create_default_context()

    reader, writer = await asyncio.open_connection(
        'example.com', 443, ssl=ssl_context, ssl_handshake_timeout=5
    )
    request = "GET / HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n"
    writer.write(request.encode())
    await writer.drain()

    response = await reader.read()
    print(response.decode(errors="ignore"))

    writer.close()
    await writer.wait_closed()

asyncio.run(main())
