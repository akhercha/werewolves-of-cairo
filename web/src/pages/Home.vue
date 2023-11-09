<template>
  <div class="flex flex-col items-center justify-center w-full h-full gap-8">
    <h1 class="text-xl">Werewolves of Cairo</h1>
    <div class="flex flex-col gap-4">
      <div>
        <p class="font-semibold">Node Url</p>
        <p>{{ state.nodeUrl }}</p>
      </div>
      <div>
        <p class="font-semibold">Master Address</p>
        <p>{{ state.masterAddress }}</p>
      </div>
      <div>
        <p class="font-semibold">Master Private Key</p>
        <p>{{ state.masterPrivateKey }}</p>
      </div>
      <div>
        <p class="font-semibold">Account Class Hash</p>
        <p>{{ state.accountClassHash }}</p>
      </div>
      <div>
        <p class="font-semibold">Active account:</p>
        <p>{{ state.activeAccount || 'Null' }}</p>
      </div>
      <input type="button" value="Yo" @click="handleClick" />
    </div>
  </div>
</template>

<script setup>
import { Account, RpcProvider } from 'starknet'
import { BurnerManager } from '@dojoengine/create-burner'

const state = reactive({
  nodeUrl: import.meta.env.VITE_PUBLIC_NODE_URL,
  masterAddress: import.meta.env.VITE_PUBLIC_MASTER_ADDRESS,
  masterPrivateKey: import.meta.env.VITE_PUBLIC_MASTER_PRIVATE_KEY,
  accountClassHash: import.meta.env.VITE_PUBLIC_ACCOUNT_CLASS_HASH,

  manager: null,
  activeAccount: null,
})

onMounted(async () => {
  const provider = new RpcProvider({
    nodeUrl: import.meta.env.VITE_PUBLIC_NODE_URL,
  })

  console.log(provider)

  const masterAddress = import.meta.env.VITE_PUBLIC_MASTER_ADDRESS
  const privateKey = import.meta.env.VITE_PUBLIC_MASTER_PRIVATE_KEY
  const masterAccount = new Account(provider, masterAddress, privateKey)

  const manager = new BurnerManager({
    masterAccount: masterAccount,
    accountClassHash: import.meta.env.VITE_PUBLIC_ACCOUNT_CLASS_HASH,
    rpcProvider: provider,
  })
  manager.init()
  state.manager = manager
  const activeAccount = manager.getActiveAccount()
  state.activeAccount = activeAccount
  console.log(activeAccount)

  // console.log(await manager.create())
})

const handleClick = () => {
  console.log(state.manager.getActiveAccount())
}
</script>
