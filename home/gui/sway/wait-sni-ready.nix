# Wait until a StatusNotifierItem tray implementation is available
#
# This horror has to exist because
#
#  - SNI spec mandates that if `IsStatusNotifierHostRegistered` is not set,
#    the client should fall back to the Freedesktop System Tray specification
#    (XEmbed).
#  - There are actual implementations that take this seriously and implement
#    a fallback *even if* StatusNotifierWatcher is already DBus-activated.
#  - https://github.com/systemd/systemd/issues/3750
#
# https://github.com/alebastr/sway-systemd/blob/main/src/wait-sni-ready
{pkgs}:
pkgs.writers.writePython3Bin "wait-sni-ready" {libraries = builtins.attrValues {inherit (pkgs.python3Packages) tenacity dbus-next;};} ''
  """
  A simple script for waiting until an org.kde.StatusNotifierItem host
  implementation is available and ready.

  Dependencies: dbus-next, tenacity
  """
  import asyncio
  import logging
  import os

  from dbus_next.aio import MessageBus
  from tenacity import retry, stop_after_delay, wait_fixed

  LOG = logging.getLogger("wait-sni-host")
  TIMEOUT = int(os.environ.get("SNI_WAIT_TIMEOUT", default=25))


  @retry(reraise=True, stop=stop_after_delay(TIMEOUT), wait=wait_fixed(0.5))
  async def get_service(bus, name, object_path, interface_name):
      """Wait until the service appears on the bus"""
      introspection = await bus.introspect(name, object_path)
      proxy = bus.get_proxy_object(name, object_path, introspection)
      return proxy.get_interface(interface_name)


  async def wait_sni_host(bus: MessageBus):
      """Wait until a StatusNotifierWatcher service is available and has a
      StatusNotifierHost instance"""
      future = asyncio.get_event_loop().create_future()

      async def on_host_registered():
          value = await sni_watcher.get_is_status_notifier_host_registered()
          LOG.debug("StatusNotifierHostRegistered: %s", value)
          if value:
              future.set_result(value)

      sni_watcher = await get_service(bus, "org.kde.StatusNotifierWatcher",
                                      "/StatusNotifierWatcher",
                                      "org.kde.StatusNotifierWatcher")
      sni_watcher.on_status_notifier_host_registered(on_host_registered)
      # fetch initial value
      await on_host_registered()
      return await asyncio.wait_for(future, timeout=TIMEOUT)


  async def main():
      """asyncio entrypoint"""
      bus = await MessageBus().connect()
      try:
          await wait_sni_host(bus)
          LOG.info("Successfully waited for org.kde.StatusNotifierHost")
      # pylint: disable=broad-except
      except Exception as err:
          LOG.error("Failed to wait for org.kde.StatusNotifierHost: %s",
                    str(err))


  if __name__ == "__main__":
      logging.basicConfig(level=logging.INFO)
      asyncio.run(main())
''
