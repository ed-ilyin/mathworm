<script lang="ts">
	export let tag = '';
	export let vector: number[] = [];
</script>

<tr>
	<td>{tag}</td>
	{#each vector as v} <td>{Math.round(v)}</td> {/each}
	<td>
		{Math.round(Math.sqrt(vector.map((x) => x ** 2).reduce((p, c) => p + c, 0)))}
	</td>
</tr>

<style>
	td {
		width: 42px;
	}
</style>
