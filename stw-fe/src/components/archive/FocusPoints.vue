<template>
    <table class="table">
        <thead>
            <tr>
                <th></th>
                <th>Sustainability</th>
                <th>Economy</th>
                <th>Political</th>
                <th>Technology</th>
                <th>Culture</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>Current points</td>
                <td>{{gameData.focusPoints.sustainability}} (+ {{gameData.focusPointsFromLevel.sustainability}})</td>
                <td>{{gameData.focusPoints.economy}} (+ {{gameData.focusPointsFromLevel.economy}})</td>
                <td>{{gameData.focusPoints.political}} (+ {{gameData.focusPointsFromLevel.political}})</td>
                <td>{{gameData.focusPoints.technology}} (+ {{gameData.focusPointsFromLevel.technology}})</td>
                <td>{{gameData.focusPoints.culture}} (+ {{gameData.focusPointsFromLevel.culture}})</td>
            </tr>
            <tr>
                <td>Level</td>
                <td>{{gameData.level.sustainability}} (need: {{gameData.focusPointsForNextLevel.sustainability}})</td>
                <td>{{gameData.level.economy}} (need: {{gameData.focusPointsForNextLevel.economy}})</td>
                <td>{{gameData.level.political}} (need: {{gameData.focusPointsForNextLevel.political}})</td>
                <td>{{gameData.level.technology}} (need: {{gameData.focusPointsForNextLevel.technology}})</td>
                <td>{{gameData.level.culture}} (need: {{gameData.focusPointsForNextLevel.culture}})</td>
            </tr>
        </tbody>
    </table>
</template>

<script>
export default {
    name: "FocusPoints",
    props: {
        gameData: Object
    }
}
</script>

<style>

</style>