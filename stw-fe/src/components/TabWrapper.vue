<template>
    <div class="tabs">
        <ul class="nav nav-tabs">
            <li v-for="title in tabTitles" 
            :key="title"
            @click="selectedTitle = title"
            v-bind:class="selectedTitle == title ? 'nav-item active' : 'nav-item'"
            >
                <a class="nav-link" href="#">{{ title }}</a>
            </li>
        </ul>
        <slot />
    </div>
</template>

<script>

import { ref, provide } from 'vue';

export default {
    setup(props, { slots }) {
        const tabTitles = ref(slots.default().map((tab) => tab.props.title))
        const selectedTitle = ref(tabTitles.value[0])

        provide("selectedTitle", selectedTitle)
        return {
            selectedTitle,
            tabTitles
        }
    },
}
</script>