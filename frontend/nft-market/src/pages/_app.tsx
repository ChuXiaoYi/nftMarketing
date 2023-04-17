import { WagmiConfig, createClient } from "wagmi";
import { getDefaultProvider } from "ethers";

import "@/styles/globals.css";
import type { AppProps } from "next/app";
import Layout from "../../components/layout";

const client = createClient({
  autoConnect: true,
  provider: getDefaultProvider(),
});

export default function App({ Component, pageProps }: AppProps) {
  return (
    // <Layout>
    <WagmiConfig client={client}>
      <Component {...pageProps} />
    </WagmiConfig>
    // </Layout>
  );
}
