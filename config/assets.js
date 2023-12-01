import * as assets from "hanami-assets";

await assets.run({
  esbuildOptionsFn: (args, esbuildOptions) => {
    esbuildOptions.logLevel = "info";

    return esbuildOptions;
  }
});
