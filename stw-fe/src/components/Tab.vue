<template>
    <div class="container p-3" v-show="title == selectedTitle">
        <slot />
    </div>
</template>
<script>
import { inject } from 'vue'

export default {
    props: ['title'],
    setup() {
        const selectedTitle = inject("selectedTitle")

        return {
            selectedTitle
        }
    },
}
</script>